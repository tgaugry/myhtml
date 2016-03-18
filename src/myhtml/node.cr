module Myhtml
  struct Node
    def self.from_raw(tree : Lib::MyhtmlTreeT*, raw_node : Lib::MyhtmlTreeNodeT*) : Node?
      unless raw_node.null?
        Node.new(tree, raw_node)
      end
    end

    def initialize(@tree : Lib::MyhtmlTreeT*, @node : Lib::MyhtmlTreeNodeT*)
    end

    def child
      Node.from_raw(@tree, Lib.node_child(@node))
    end

    def next
      Node.from_raw(@tree, Lib.node_next(@node))
    end

    def tag_id
      Lib.node_tag_id(@node)
    end

    def tag_name_slice
      res = Lib.tag_name_by_id(@tree, tag_id, out length)
      Slice.new(res, length)
    end

    def tag_name
      String.new(tag_name_slice)
    end

    def tag_text_slice
      res = Lib.node_text(@node, out length)
      Slice.new(res, length)
    end

    def tag_text
      String.new(tag_text_slice)
    end

    def each_attribute(&block)
      attr = Lib.node_attribute_first(@node)
      while !attr.null?
        name = Lib.attribute_name(attr, out name_length)
        value = Lib.attribute_value(attr, out value_length)
        name_slice = Slice(UInt8).new(name, name_length)
        value_slice = Slice(UInt8).new(value, value_length)
        yield name_slice, value_slice
        attr = Lib.attribute_next(attr)
      end
    end

    def attributes
      @attributes ||= begin
        res = {} of String => String
        each_attribute do |k, v|
          res[String.new(k)] = String.new(v)
        end
        res
      end
    end
  end
end

module Myhtml
  struct Node
    def self.from_raw(tree : Tree, raw_node : Lib::MyhtmlTreeNodeT*) : Node?
      unless raw_node.null?
        Node.new(tree, raw_node)
      end
    end

    def initialize(@tree : Tree, @node : Lib::MyhtmlTreeNodeT*)
    end

    {% for name in %w(child next parent prev last_child) %}
      def {{name.id}}
        Node.from_raw(@tree, Lib.node_{{name.id}}(@node))
      end

      def {{name.id}}!
        self.{{name.id}}.not_nil!
      end
    {% end %}

    def tag_id
      Lib.node_tag_id(@node)
    end

    def tag_name_slice
      res = Lib.tag_name_by_id(@tree.raw_tree, tag_id, out length)
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
      name_length = LibC::SizeT.new(0)
      value_length = LibC::SizeT.new(0)
      while !attr.null?
        name = Lib.attribute_name(attr, pointerof(name_length))
        value = Lib.attribute_value(attr, pointerof(value_length))
        name_slice = Slice(UInt8).new(name, name_length)
        value_slice = Slice(UInt8).new(value, value_length)
        yield name_slice, value_slice
        attr = Lib.attribute_next(attr)
      end
    end

    def attribute_by(string : String)
      each_attribute do |k, v|
        return String.new(v) if k == string.to_slice
      end
    end

    def attribute_by(slice : Slice(UInt8))
      each_attribute do |k, v|
        return v if k == slice
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

    def each_child(&block : Node ->)
      child = self.child
      while child
        yield child
        child = child.next
      end
      self
    end

    def children
      res = [] of Node
      each_child { |node| res << node }
      res
    end

    def each_parent(&block : Node ->)
      parent = self.parent
      while parent
        break if parent.tag_id == Lib::MyhtmlTags::MyHTML_TAG__UNDEF
        yield parent
        parent = parent.parent
      end
      self
    end

    def parents
      res = [] of Node
      each_parent { |node| res << node }
      res
    end

    def left_iterator
      LeftIterator.new(self)
    end

    def right_iterator
      RightIterator.new(self)
    end

    def visible?
      case tag_id
      when Lib::MyhtmlTags::MyHTML_TAG_STYLE,
           Lib::MyhtmlTags::MyHTML_TAG_COMMENT,
           Lib::MyhtmlTags::MyHTML_TAG_SCRIPT
        false
      else
        true
      end
    end
  end
end

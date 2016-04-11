module Myhtml
  struct Node
    @node : Lib::MyhtmlTreeNodeT*

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

    def tag_sym
      Myhtml.symbol_by_tag_id(tag_id)
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

    def children
      ChildrenIterator.new(self)
    end

    def deep_children
      DeepChildrenIterator.new(self)
    end

    def walk_tree(level = 0, &block : Node, Int32 ->)
      yield self, level
      children.each { |child| child.walk_tree(level + 1, &block) }
    end

    def parents
      ParentsIterator.new(self)
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
           Lib::MyhtmlTags::MyHTML_TAG_SCRIPT,
           Lib::MyhtmlTags::MyHTML_TAG_HEAD
        false
      else
        true
      end
    end

    def object?
      case tag_id
      when Lib::MyhtmlTags::MyHTML_TAG_APPLET,
           Lib::MyhtmlTags::MyHTML_TAG_IFRAME,
           Lib::MyhtmlTags::MyHTML_TAG_FRAME,
           Lib::MyhtmlTags::MyHTML_TAG_FRAMESET,
           Lib::MyhtmlTags::MyHTML_TAG_EMBED,
           Lib::MyhtmlTags::MyHTML_TAG_OBJECT
        true
      else
        false
      end
    end

    {% for name in Lib::MyhtmlTags.constants %}
      def is_tag_{{ name.gsub(/MyHTML_TAG_/, "").downcase.id }}?
        tag_id == Lib::MyhtmlTags::{{ name.id }}
      end
    {% end %}

    def is_text?
      tag_id == Lib::MyhtmlTags::MyHTML_TAG__TEXT
    end

    def is_tag_noindex?
      tag_id >= Lib::MyhtmlTags::MyHTML_TAG_LAST_ENTRY && tag_name_slice == "noindex".to_slice
    end

    def deepest_child
      last_child.try(&.deepest_child) || self
    end

    # left node to current
    def left
      prev.try(&.deepest_child) || parent
    end

    def left!
      left.not_nil!
    end

    def next_parent
      if p = self.parent
        p.next || p.next_parent
      end
    end

    # right node to current
    def right
      child || self.next || next_parent
    end

    def flat_right
      self.next || next_parent
    end

    def flat_right!
      flat_right.not_nil!
    end

    def right!
      right.not_nil!
    end
  end
end

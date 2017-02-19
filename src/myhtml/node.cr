require "./tag_id_utils"

module Myhtml
  struct Node
    @node : Lib::MyhtmlTreeNodeT*
    @attributes : Hash(String, String)?

    include TagIdUtils

    def self.from_raw(tree : Tree, raw_node : Lib::MyhtmlTreeNodeT*) : Node?
      unless raw_node.null?
        Node.new(tree, raw_node)
      end
    end

    def initialize(@tree : Tree, @node : Lib::MyhtmlTreeNodeT*)
    end

    def raw_node
      @node
    end

    getter tree

    def raw_tree
      @tree.raw_tree
    end

    {% for name in %w(child next parent prev last_child) %}
      def {{name.id}}
        Node.from_raw(@tree, Lib.node_{{name.id}}(@node))
      end
    {% end %}

    {% for name in %w(child next parent prev last_child lastest_child left right next_parent flat_right) %}
      def {{name.id}}!
        if val = self.{{ name.id }}
          val
        else
          raise Error.new("Empty node, '{{name.id}}' called from #{self.inspect}")
        end
      end
    {% end %}

    def remove!
      Lib.node_remove(@node)
    end

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

    protected def each_raw_attribute(&block)
      attr = Lib.node_attribute_first(@node)
      while !attr.null?
        yield attr
        attr = Lib.attribute_next(attr)
      end
    end

    def any_attribute?
      !Lib.node_attribute_first(@node).null?
    end

    def each_attribute(&block)
      name_length = LibC::SizeT.new(0)
      value_length = LibC::SizeT.new(0)
      each_raw_attribute do |attr|
        name = Lib.attribute_key(attr, pointerof(name_length))
        value = Lib.attribute_value(attr, pointerof(value_length))
        name_slice = Slice(UInt8).new(name, name_length)
        value_slice = Slice(UInt8).new(value, value_length)
        yield name_slice, value_slice
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

    def scope
      ScopeIterator.new(self)
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

    def lastest_child
      result_node = self
      while current_node = result_node.last_child
        result_node = current_node
      end
      result_node
    end

    # left node to current
    def left
      prev.try(&.lastest_child) || parent
    end

    protected def next_parent
      current_node = self
      while current_node = current_node.parent
        nxt = current_node.next
        return nxt if nxt
      end
    end

    # right node to current
    def right
      child || self.next || next_parent
    end

    def flat_right
      self.next || next_parent
    end

    def data=(d : Void*)
      Lib.node_set_data(@node, d)
    end

    def data
      Lib.node_get_data(@node)
    end

    def nodes_by_attribute(key : String, value : String, case_sensitive = false)
      col = Lib.get_nodes_by_attribute_value(@tree.raw_tree, nil, @node, case_sensitive, key.to_unsafe, key.bytesize, value.to_unsafe, value.bytesize, out status)
      if status != Lib::MyhtmlStatus::MyHTML_STATUS_OK
        Lib.collection_destroy(col)
        raise Error.new("nodes_by_attribute error #{status}, for `#{key}`, `#{value}`")
      end

      CollectionIterator.new(@tree, col)
    end

    def to_html
      str = Lib::MyhtmlStringRawT.new
      Lib.string_raw_clean_all(pointerof(str))
      if Lib.serialization(@node, pointerof(str))
        res = String.new(str.data, str.length)
        Lib.string_raw_destroy(pointerof(str), false)
        res
      else
        raise Error.new("Unknown problem with serialization")
      end
    end

    # def serialize
    #   str = Lib::MyhtmlStringRawT.new
    #   Lib.string_raw_clean_all(pointerof(str))
    #   if Lib.serialization_node(@tree.raw_tree, @node, pointerof(str))
    #     res = String.new(str.data, str.length)
    #     Lib.string_raw_destroy(pointerof(str), false)
    #     res
    #   else
    #     raise Error.new("Unknown problem with serialization")
    #   end
    # end

    def inner_text(join_with : String | Char | Nil = nil, deep = true)
      String.build do |buf|
        (deep ? scope : children).nodes(:_text).each_with_index do |node, i|
          buf << join_with if join_with && i != 0
          part = node.tag_text
          part = part.strip if join_with
          buf << part
        end
      end
    end

    def inspect(io : IO)
      io << "Myhtml::Node("
      io << "tag_name: "
      tag_name.inspect(io)
      case _tag_id = tag_id
      when Lib::MyhtmlTags::MyHTML_TAG__TEXT,
           Lib::MyhtmlTags::MyHTML_TAG__COMMENT,
           Lib::MyhtmlTags::MyHTML_TAG_STYLE,
           Lib::MyhtmlTags::MyHTML_TAG_SCRIPT
        text = tag_text
        text = text.size > 30 ? text[0..30] + "...)" : text
        io << ", tag_text: "
        text.inspect(io)
      end

      if (_tag_id != Lib::MyhtmlTags::MyHTML_TAG__TEXT && _tag_id != Lib::MyhtmlTags::MyHTML_TAG__COMMENT) && any_attribute?
        io << ", attributes: "
        attributes.inspect(io)
      end
      io << ")"
    end
  end
end

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
          raise EmptyNodeError.new("'{{name.id}}' called from #{self.inspect}")
        end
      end
    {% end %}

    def remove!
      Lib.node_remove(@node)
    end

    @[AlwaysInline]
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

    def tag_text_set(text : String, encoding)
      Lib.node_text_set_with_charef(@node, text.to_unsafe, text.bytesize, encoding)
    end

    protected def each_raw_attribute(&block)
      attr = Lib.node_attribute_first(@node)
      while !attr.null?
        yield attr
        attr = Lib.attribute_next(attr)
      end
      nil
    end

    @[AlwaysInline]
    def any_attribute?
      !Lib.node_attribute_first(@node).null?
    end

    def each_attribute(&block)
      each_raw_attribute do |attr|
        yield attribute_name(attr), attribute_value(attr)
      end
    end

    @[AlwaysInline]
    private def attribute_name(attr)
      name = Lib.attribute_key(attr, out name_length)
      Slice(UInt8).new(name, name_length)
    end

    @[AlwaysInline]
    private def attribute_value(attr)
      value = Lib.attribute_value(attr, out value_length)
      Slice(UInt8).new(value, value_length)
    end

    def attribute_by(string : String)
      slice = string.to_slice
      each_raw_attribute do |attr|
        if attribute_name(attr) == slice
          return String.new(attribute_value(attr))
        end
      end
    end

    def attribute_by(slice : Slice(UInt8))
      each_raw_attribute do |attr|
        if attribute_name(attr) == slice
          return attribute_value(attr)
        end
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
      if status != Lib::MyStatus::MyCORE_STATUS_OK
        Lib.collection_destroy(col)
        raise Error.new("nodes_by_attribute error #{status}, for `#{key}`, `#{value}`")
      end

      Iterator.new(@tree, col)
    end

    def to_html(deep = true)
      str = Lib::MyhtmlStringRawT.new

      Lib.string_raw_clean_all(pointerof(str))

      res = if deep
              Lib.serialization(@node, pointerof(str))
            else
              Lib.serialization_node(@node, pointerof(str))
            end

      if res == Lib::MyStatus::MyCORE_STATUS_OK
        res = String.new(str.data, str.length)
        Lib.string_raw_destroy(pointerof(str), false)
        res
      else
        Lib.string_raw_destroy(pointerof(str), false)
        raise Error.new("Unknown problem with serialization: #{res}")
      end
    end

    SERIALIZE_CALLBACK = ->(text : UInt8*, length : LibC::SizeT, data : Void*) do
      cbk = Box(Bytes ->).unbox(data)
      cbk.call(Bytes.new(text, length))
      Lib::MyStatus::MyCORE_STATUS_OK
    end

    def to_html(io : IO, deep = true)
      cbk = ->(b : Bytes) do
        io.write(b)
      end

      if deep
        Lib.serialization_tree_callback(@node, SERIALIZE_CALLBACK, Box.box(cbk))
      else
        Lib.serialization_node_callback(@node, SERIALIZE_CALLBACK, Box.box(cbk))
      end

      cbk
    end

    def inner_text(join_with : String | Char | Nil = nil, deep = true)
      String.build { |io| inner_text(io, join_with: join_with, deep: deep) }
    end

    def inner_text(io : IO, join_with : String | Char | Nil = nil, deep = true)
      if (join_with == nil) || (join_with == "")
        each_inner_text(deep: deep) { |slice| io.write slice }
      else
        i = 0
        each_inner_text(deep: deep) do |slice|
          io << join_with if i != 0
          io.write Utils.strip_slice(slice)
          i += 1
        end
      end
    end

    def each_inner_text(deep = true)
      (deep ? scope : children).nodes(Lib::MyhtmlTags::MyHTML_TAG__TEXT).each { |node| yield node.tag_text_slice }
    end

    def inspect(io : IO)
      io << "Myhtml::Node(tag_name: "
      Utils.string_slice_to_io_limited(tag_name_slice, io)

      case _tag_id = tag_id
      when Lib::MyhtmlTags::MyHTML_TAG__TEXT,
           Lib::MyhtmlTags::MyHTML_TAG__COMMENT,
           Lib::MyhtmlTags::MyHTML_TAG_STYLE
        io << ", tag_text: "
        Utils.string_slice_to_io_limited(tag_text_slice, io)
      else
        _attributes = @attributes

        if _attributes || any_attribute?
          io << ", attributes: {"
          c = 0
          if _attributes
            _attributes.each do |key, value|
              io << ", " unless c == 0
              Utils.string_slice_to_io_limited(key.to_slice, io)
              io << " => "
              Utils.string_slice_to_io_limited(value.to_slice, io)
              c += 1
            end
          else
            each_attribute do |key_slice, value_slice|
              io << ", " unless c == 0
              Utils.string_slice_to_io_limited(key_slice, io)
              io << " => "
              Utils.string_slice_to_io_limited(value_slice, io)
              c += 1
            end
          end
          io << '}'
        end
      end

      io << ')'
    end
  end
end

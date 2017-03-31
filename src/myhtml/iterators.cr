require "./node"

module Myhtml
  module TagsIterator
    def nodes(tag_id : Lib::MyhtmlTags)
      self.select { |node| node.tag_id == tag_id }
    end

    @[AlwaysInline]
    def nodes(tag_sym : Symbol)
      nodes(Myhtml.tag_id_by_symbol(tag_sym))
    end

    @[AlwaysInline]
    def nodes(tag_str : String)
      nodes(Myhtml.tag_id_by_string(tag_str))
    end
  end

  struct RightIterator
    include ::Iterator(Node)
    include TagsIterator

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = @current_node.not_nil!.right
      @current_node || stop
    end

    def rewind
      @current_node = @start_node
    end
  end

  struct LeftIterator
    include ::Iterator(Node)
    include TagsIterator

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = @current_node.not_nil!.left

      if (cn = @current_node) && (cn.tag_id != Lib::MyhtmlTags::MyHTML_TAG__UNDEF)
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
    end
  end

  struct ChildrenIterator
    include ::Iterator(Node)
    include TagsIterator

    @current_node : Node?

    def initialize(@start_node : Node)
      rewind
    end

    def next
      if cn = @current_node
        @current_node = cn.next
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node.child
    end
  end

  struct ScopeIterator
    include ::Iterator(Node)
    include TagsIterator

    @stop_node : Node?

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = @current_node.not_nil!.right
      return stop if @current_node == @stop_node
      @current_node || stop
    end

    def rewind
      @current_node = @start_node
      @stop_node = @start_node.flat_right
    end
  end

  struct ParentsIterator
    include ::Iterator(Node)
    include TagsIterator

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = @current_node.not_nil!.parent
      if (cn = @current_node) && (cn.tag_id != Lib::MyhtmlTags::MyHTML_TAG__UNDEF)
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
    end
  end

  class Iterator
    include ::Iterator(Node)

    @length : LibC::SizeT
    @list : Lib::MyhtmlTreeNodeT**
    getter raw_collection

    def initialize(@tree : Tree, @raw_collection : Lib::MyhtmlCollectionT*)
      @id = 0
      unless @raw_collection.null?
        @length = @raw_collection.value.length
        @list = @raw_collection.value.list
      else
        @length = LibC::SizeT.new(0)
        @list = Pointer(Lib::MyhtmlTreeNodeT*).new(0)
      end
      @finalized = false
    end

    def next
      if @id < @length
        node = @list[@id]
        @id += 1
        Node.new(@tree, node)
      else
        stop
      end
    end

    def size
      @length
    end

    def finalize
      free
    end

    def free
      unless @finalized
        @finalized = true
        Lib.collection_destroy(@raw_collection)
      end
    end

    def rewind
      @id = 0
    end

    def inspect(io)
      io << "#<Myhtml::Iterator:0x"
      object_id.to_s(16, io)
      io << " elements: "
      @length.inspect(io)
      io << ", "
      io << "current: "
      @id.inspect(io)
      io << '>'
    end
  end
end

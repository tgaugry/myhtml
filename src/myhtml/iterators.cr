module Myhtml
  module TagsIterator
    def tags(tag_id : Myhtml::Lib::MyhtmlTags)
      select { |node| node.tag_id == tag_id }
    end

    def tags(tag_sym : Symbol)
      tags(Myhtml.tag_id_by_symbol(tag_sym))
    end
  end

  struct RightIterator
    include Iterator(Node)
    include TagsIterator

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = @current_node.not_nil!.right

      if cn = @current_node
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
      self
    end
  end

  struct LeftIterator
    include Iterator(Node)
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
      self
    end
  end

  struct ChildrenIterator
    include Iterator(Node)
    include TagsIterator

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

  struct DeepChildrenIterator
    include Iterator(Node)
    include TagsIterator

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = @current_node.not_nil!.right
      return stop if @current_node == @stop_node

      if cn = @current_node
        cn
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
      @stop_node = @start_node.try(&.next) || @start_node.next_parent
    end
  end

  struct ParentsIterator
    include Iterator(Node)
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

  struct EachTagIterator
    include Iterator(Node)

    def initialize(@tree, @tag_id)
      @tag_index = Pointer(Lib::MyhtmlTagIndexT).null
      @index_node = Pointer(Lib::MyhtmlTagIndexNodeT).null
      rewind
    end

    def next
      return stop if @index_node.null?

      node = Lib.tag_index_tree_node(@index_node)
      if node.null?
        stop
      else
        @index_node = Lib.tag_index_next(@index_node)
        Node.new(@tree, node)
      end
    end

    def rewind
      @tag_index = Lib.tree_get_tag_index(@tree.raw_tree)
      @index_node = Lib.tag_index_first(@tag_index, @tag_id)
    end

    def count
      Lib.tag_index_entry_count(@tag_index, @tag_id)
    end

    def size
      count
    end
  end
end

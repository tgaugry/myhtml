module Myhtml
  class RightIterator
    include Iterator(Node)

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = next_to(@current_node.not_nil!)

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

    private def next_to(node)
      node.child || node.next || next_parent(node)
    end

    private def next_parent(node)
      if parent = node.parent
        parent.next || next_parent(parent)
      end
    end
  end

  class LeftIterator
    include Iterator(Node)

    def initialize(@start_node : Node)
      rewind
    end

    def next
      @current_node = next_to(@current_node.not_nil!)

      if cn = @current_node
        if cn.tag_id == Lib::MyhtmlTags::MyHTML_TAG__UNDEF
          stop
        else
          cn
        end
      else
        stop
      end
    end

    def rewind
      @current_node = @start_node
      self
    end

    private def next_to(node)
      deep_child(node.prev) || node.parent
    end

    private def deep_child(node)
      return unless node

      if child = node.last_child
        deep_child(child)
      else
        node
      end
    end
  end
end

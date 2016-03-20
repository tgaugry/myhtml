module Myhtml
  class Parser
    def initialize(options = 0, threads_count = 1, queue_size = 0)
      @tree = Tree.new(options, threads_count, queue_size)
    end

    def parse(string, encoding = 0)
      res = Lib.parse(@tree.raw_tree, encoding, string.to_unsafe, string.size) # MyHTML_ENCODING_UTF_8
      if res == 0
        :ok
      else
        raise Error.new("parse error #{res}")
      end
    end

    def root
      @tree.root
    end

    def tags_count(tag_id)
      Myhtml::Lib.tag_index_entry_count(tag_index, tag_id)
    end

    def each_tag(tag_id, &block : Node ->)
      index_node = Lib.tag_index_first(tag_index, tag_id)
      while !index_node.null?
        node = Lib.tag_index_tree_node(index_node)
        unless node.null?
          node = Node.from_raw(@tree, node).not_nil!
          yield node
          index_node = Lib.tag_index_next(index_node)
        else
          break
        end
      end
      self
    end

    private def tag_index
      @tag_index ||= Lib.tree_get_tag_index(@tree.raw_tree)
    end
  end
end

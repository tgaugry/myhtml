module Myhtml
  class Tree
    getter raw_myhtml, raw_tree

    def initialize(options = 0, threads_count = 1, queue_size = 0)
      @raw_myhtml = Lib.create
      res = Lib.init(@raw_myhtml, options, threads_count, queue_size) # MyHTML_OPTIONS_DEFAULT
      if res != Lib::MyhtmlStatus::MyHTML_STATUS_OK
        raise Error.new("init error #{res}")
      end

      @raw_tree = Lib.tree_create
      res = Lib.tree_init(@raw_tree, @raw_myhtml)

      if res != Lib::MyhtmlStatus::MyHTML_STATUS_OK
        raise Error.new("tree_init error #{res}")
      end
    end

    def finalize
      Lib.tree_destroy(@raw_tree)
      Lib.destroy(@raw_myhtml)
    end

    def root
      Node.from_raw(self, Lib.tree_get_node_html(@raw_tree))
    end
  end
end

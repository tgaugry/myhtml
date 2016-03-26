module Myhtml
  class Tree
    getter raw_myhtml, raw_tree

    def initialize(options = Lib::MyhtmlOptions::MyHTML_OPTIONS_DEFAULT, threads_count = 1, queue_size = 0)
      @raw_myhtml = Lib.create
      res = Lib.init(@raw_myhtml, options, threads_count, queue_size)
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

    def root!
      root.not_nil!
    end

    def html
      root
    end

    def html!
      html.not_nil!
    end

    def head
      Node.from_raw(self, Lib.tree_get_node_head(@raw_tree))
    end

    def head!
      head.not_nil!
    end

    def body
      Node.from_raw(self, Lib.tree_get_node_body(@raw_tree))
    end

    def body!
      body.not_nil!
    end
  end
end

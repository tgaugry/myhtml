module Myhtml
  class Parser
    getter :myhtml, :tree

    def initialize(options = 0, threads_count = 1, queue_size = 0)
      @myhtml = Lib.create
      res = Lib.init(@myhtml, options, threads_count, queue_size) # MyHTML_OPTIONS_DEFAULT
      
      if res != 0 # OK_STATUS
        raise Error.new("init error #{res}")
      end

      @tree = Lib.tree_create
      res = Lib.tree_init(@tree, @myhtml)

      if res != 0 # OK_STATUS
        raise Error.new("tree_init error #{res}")
      end
    end

    def parse(string, encoding = 0)
      res = Lib.parse(@tree, encoding, string.to_unsafe, string.size) # MyHTML_ENCODING_UTF_8
      if res == 0
        :ok
      else
        raise Error.new("parse error #{res}")
      end
    end

    def root
      Node.from_raw(@tree, Lib.tree_get_node_html(@tree))
    end

    def finalize
      Lib.tree_destroy(@tree)
      Lib.destroy(@myhtml)
    end
  end
end

module Myhtml
  class Tree
    getter tree
    
    def initialize(myhtml)
      @tree = Lib.tree_create
      res = Lib.tree_init(@tree, myhtml)

      if res != 0 # OK_STATUS
        raise Error.new("tree_init error #{res}")
      end
    end

    def finalize
      Lib.tree_destroy(@tree)
    end
  end
end

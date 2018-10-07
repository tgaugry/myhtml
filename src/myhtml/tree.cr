class Myhtml::Tree
  # :nodoc:
  property encoding : Lib::MyEncodingList

  # :nodoc:
  getter raw_tree : Lib::MyhtmlTreeT*

  def initialize(@encoding = Lib::MyEncodingList::MyENCODING_DEFAULT)
    options = Lib::MyhtmlOptions::MyHTML_OPTIONS_PARSE_MODE_SINGLE
    threads_count = 1
    queue_size = 0

    @raw_myhtml = Lib.create
    res = Lib.init(@raw_myhtml, options, threads_count, queue_size)
    if res != Lib::MyStatus::MyCORE_STATUS_OK
      raise Error.new("init error #{res}")
    end

    @raw_tree = Lib.tree_create
    res = Lib.tree_init(@raw_tree, @raw_myhtml)

    if res != Lib::MyStatus::MyCORE_STATUS_OK
      Lib.destroy(@raw_myhtml)
      raise Error.new("tree_init error #{res}")
    end

    @finalized = false
  end

  def create_node(tag_sym : Symbol)
    raw_node = Lib.node_create(
      raw_tree,
      Utils::TagConverter.sym_to_id(tag_sym),
      Myhtml::Lib::MyhtmlNamespace::MyHTML_NAMESPACE_HTML
    )
    Node.new(self, raw_node)
  end

  def set_flags(flags : Lib::MyhtmlTreeParseFlags)
    Lib.tree_parse_flags_set(@raw_tree, flags)
  end

  # Dangerous, manually free object (free also safely called from GC finalize)
  def free
    unless @finalized
      @finalized = true
      Lib.tree_destroy(@raw_tree)
      Lib.destroy(@raw_myhtml)
    end
  end

  def finalize
    free
  end
end

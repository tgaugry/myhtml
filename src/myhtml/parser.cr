module Myhtml
  struct Parser
    getter tree, encoding

    @encoding : Lib::MyEncodingList

    protected def initialize(tree_options : Lib::MyhtmlTreeParseFlags? = nil, encoding : Lib::MyEncodingList? = nil, @detect_encoding_from_meta : Bool = false, @detect_encoding : Bool = false)
      options = Lib::MyhtmlOptions::MyHTML_OPTIONS_PARSE_MODE_SINGLE
      threads_count = 1
      queue_size = 0
      @encoding = encoding || Lib::MyEncodingList::MyENCODING_DEFAULT
      @tree = Tree.new(options, threads_count, queue_size, tree_options)
    end

    # parse from string
    def self.new(page : String, tree_options : Lib::MyhtmlTreeParseFlags? = nil, encoding : Lib::MyEncodingList? = nil, detect_encoding_from_meta : Bool = false, detect_encoding : Bool = false)
      self.new(tree_options: tree_options, encoding: encoding, detect_encoding_from_meta: detect_encoding_from_meta, detect_encoding: detect_encoding).parse(page)
    end

    # parse from stream
    def self.new(io : IO, tree_options : Lib::MyhtmlTreeParseFlags? = nil, encoding : Lib::MyEncodingList? = nil)
      self.new(tree_options: tree_options, encoding: encoding).parse_stream(io)
    end

    protected def parse(string)
      pointer = string.to_unsafe
      bytesize = string.bytesize

      if Lib.encoding_detect_and_cut_bom(pointer, bytesize, out encoding2, out pointer2, out bytesize2)
        pointer = pointer2
        bytesize = bytesize2
        @encoding = encoding2
      else
        detected = false

        if @detect_encoding_from_meta
          enc = Lib.encoding_prescan_stream_to_determine_encoding(pointer, bytesize)
          if enc != Lib::MyEncodingList::MyENCODING_NOT_DETERMINED
            detected = true
            @encoding = enc
          end
        end

        if @detect_encoding && !detected
          if Lib.encoding_detect(pointer, bytesize, out enc2)
            @encoding = enc2
          end
        end
      end

      res = Lib.parse(@tree.raw_tree, @encoding, pointer, bytesize)
      if res != Lib::MyStatus::MyCORE_STATUS_OK
        free
        raise Error.new("parse error #{res}")
      end

      self
    end

    BUFFER_SIZE = 8192

    protected def parse_stream(io : IO)
      buffers = Array(Bytes).new
      Lib.encoding_set(@tree.raw_tree, @encoding)

      loop do
        buffer = Bytes.new(BUFFER_SIZE)
        read_size = io.read(buffer)
        break if read_size == 0

        buffers << buffer
        res = Lib.parse_chunk(@tree.raw_tree, buffer.to_unsafe, read_size)
        if res != Lib::MyStatus::MyCORE_STATUS_OK
          free
          raise Error.new("parse_chunk error #{res}")
        end
      end

      res = Lib.parse_chunk_end(@tree.raw_tree)
      if res != Lib::MyStatus::MyCORE_STATUS_OK
        free
        raise Error.new("parse_chunk_end error #{res}")
      end

      self
    end

    # Dangerous, free object
    def free
      @tree.free
    end

    {% for name in %w(root html head body) %}
      delegate {{ name.id }}, to: @tree
      delegate {{ name.id }}!, to: @tree
    {% end %}

    def nodes(tag_id : Myhtml::Lib::MyhtmlTags)
      Iterator.new(@tree, Lib.get_nodes_by_tag_id(@tree.raw_tree, nil, tag_id, out status))
    end

    def nodes(tag_sym : Symbol)
      nodes(Myhtml.tag_id_by_symbol(tag_sym))
    end

    def nodes(tag_str : String)
      nodes(Myhtml.tag_id_by_string(tag_str))
    end
  end
end

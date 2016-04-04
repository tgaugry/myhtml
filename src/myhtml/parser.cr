module Myhtml
  class Parser
    def initialize(options = Lib::MyhtmlOptions::MyHTML_OPTIONS_DEFAULT, threads_count = 1, queue_size = 0)
      @tree = Tree.new(options, threads_count, queue_size)
    end

    def parse(string, encoding = Lib::MyhtmlEncodingList::MyHTML_ENCODING_UTF_8)
      pointer = string.to_unsafe
      bytesize = string.bytesize

      if Lib.encoding_detect_and_cut_bom(pointer, bytesize, out encoding2, out pointer2, out bytesize2)
        pointer = pointer2
        bytesize = bytesize2
        encoding = encoding2
      end

      res = Lib.parse(@tree.raw_tree, encoding, pointer, bytesize)
      raise Error.new("parse error #{res}") if res != Lib::MyhtmlStatus::MyHTML_STATUS_OK
      self
    end

    {% for name in %w(root html head body) %}
      delegate {{ name.id }}, @tree
      delegate {{ name.id }}!, @tree
    {% end %}

    def tags(tag_id : Myhtml::Lib::MyhtmlTags)
      EachTagIterator.new(@tree, tag_id)
    end

    def tags(tag_sym : Symbol)
      EachTagIterator.new(@tree, Myhtml.tag_id_by_symbol(tag_sym))
    end
  end
end

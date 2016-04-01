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

    def count_tags(tag_id)
      Lib.tag_index_entry_count(tag_index, tag_id)
    end

    def each_tag(tag_id, &block : Node ->)
      each_tag(tag_id).each { |n| block.call(n) }
    end

    def each_tag(tag_id)
      EachTagIterator.new(@tree, tag_id)
    end

    def select_tags(tag_id)
      each_tag(tag_id).to_a
    end

    private def tag_index
      Lib.tree_get_tag_index(@tree.raw_tree)
    end
  end
end

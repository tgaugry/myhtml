module Myhtml
  VERSION = "0.18"

  class Error < Exception
  end

  class EmptyNodeError < Error
  end

  def self.lib_version
    v = Lib.version
    {v.major, v.minor, v.patch}
  end

  def self.version_string
    "#{VERSION} (libmyhtml #{lib_version.join('.')})"
  end

  # !this object never freed!
  HTML_ENTITIES_NODE = Myhtml::Parser.new("1", tree_options: Myhtml::Lib::MyhtmlTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_WITHOUT_DOCTYPE_IN_TREE).body!.child!

  def self.decode_html_entities(str : String)
    HTML_ENTITIES_NODE.tag_text_set(str, Lib::MyhtmlEncodingList::MyHTML_ENCODING_DEFAULT)
    HTML_ENTITIES_NODE.tag_text
  end

  # "text/html; charset=Windows-1251" => MyHTML_ENCODING_WINDOWS_1251
  def self.parse_charset(encoding : String) : Myhtml::Lib::MyhtmlEncodingList?
    if Lib.encoding_extracting_character_encoding_from_charset(encoding.to_unsafe, encoding.bytesize, out e)
      e
    end
  end
end

require "./myhtml/*"

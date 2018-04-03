module Myhtml
  VERSION = "0.28"

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
    HTML_ENTITIES_NODE.tag_text_set(str, Lib::MyEncodingList::MyENCODING_DEFAULT)
    HTML_ENTITIES_NODE.tag_text
  end

  record EncodingNotFound, encoding : String

  # detect encoding from header, example: Myhtml.detect_encoding_from_header(headers["Content-Type"])
  #   "text/html; charset=Windows-1251" => MyHTML_ENCODING_WINDOWS_1251
  #

  def self.detect_encoding_from_header(header : String) : Lib::MyEncodingList | EncodingNotFound
    res = Lib.encoding_extracting_character_encoding_from_charset_with_found(header.to_unsafe, header.bytesize, out e, out pointer, out bytesize)

    if res
      e
    else
      EncodingNotFound.new(String.new(pointer, bytesize))
    end
  end

  def self.detect_encoding_from_header?(header) : Lib::MyEncodingList?
    enc = detect_encoding_from_header(header)
    if enc.is_a?(Lib::MyEncodingList)
      enc
    end
  end

  # detect encoding from content
  #   example: <meta http-equiv="Content-Type" content="text/html; charset=windows-1251" /> => MyHTML_ENCODING_WINDOWS_1251

  def self.detect_encoding_from_content_by_meta(content : String)
    detect_encoding_from_content_by_meta(content.to_unsafe, content.bytesize)
  end

  def self.detect_encoding_from_content_by_meta(pointer, bytesize)
    enc = Lib.encoding_prescan_stream_to_determine_encoding_with_found(pointer, bytesize, out pointer2, out bytesize2)
    if enc != Lib::MyEncodingList::MyENCODING_NOT_DETERMINED
      enc
    else
      EncodingNotFound.new(String.new(pointer2, bytesize2))
    end
  end

  def self.detect_encoding_from_content_by_meta?(content : String)
    detect_encoding_from_content_by_meta?(content.to_unsafe, content.bytesize)
  end

  def self.detect_encoding_from_content_by_meta?(pointer, bytesize)
    enc = detect_encoding_from_content_by_meta(pointer, bytesize)
    if enc.is_a?(Lib::MyEncodingList)
      enc
    end
  end

  # detect encoding by trigrams
  #

  def self.detect_encoding(content : String)
    detect_encoding?(content)
  end

  def self.detect_encoding(pointer, bytesize)
    detect_encoding?(pointer, bytesize)
  end

  def self.detect_encoding?(content : String)
    detect_encoding?(content.to_unsafe, content.bytesize)
  end

  def self.detect_encoding?(pointer, bytesize)
    if Lib.encoding_detect(pointer, bytesize, out enc)
      enc
    end
  end
end

require "./myhtml/*"

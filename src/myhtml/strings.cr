require "./constants"

module Myhtml
  module StringTag
    TAG_SYMBOL_MAP = Hash(String, Symbol).new
    {% for name in Lib::MyhtmlTags.constants.map(&.gsub(/MyHTML_TAG_/, "").downcase) %}
      TAG_SYMBOL_MAP["{{ name.id }}"] = :{{ name.id }}
    {% end %}

    def symbol_by_string!(str : String)
      TAG_SYMBOL_MAP.fetch(str) { raise Error.new("Unknown tag #{str.inspect}") }
    end
  end

  extend StringTag
end

module Myhtml::Utils::HtmlEntities
  # !this object never freed!
  HTML_ENTITIES_NODE2 = Myhtml::Tree.new.create_node(:_text)

  def self.decode(str : String, encoding = nil)
    HTML_ENTITIES_NODE2.tag_text_set(str, encoding || Lib::MyEncodingList::MyENCODING_DEFAULT)
    HTML_ENTITIES_NODE2.tag_text
  end
end

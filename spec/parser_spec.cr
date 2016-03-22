require "./spec_helper"

describe Myhtml::Node do
  it "select_tags" do
    parser = Myhtml::Parser.new
    parser.parse("<html><body><div class=AAA style='color:red'>Haha</div>
      <div>blah</div>
      </body></html>")

    parser.count_tags(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV).should eq 2
    nodes = parser.select_tags(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV)
    nodes.size.should eq 2

    node1, node2 = nodes
    node1.child!.tag_text.should eq "Haha"
    node2.child!.tag_text.should eq "blah"
  end

  it "correctly works with unicode" do
    str = <<-HTML
      <html>
      <head>
        <meta name="keywords" content="аа, ааааааааааа, ааааааааа, ааа, ааааааа, ааааааааа"  />
      </head>

      <body id='normal' >
        <a href="http://aaaa-aaa.ru/">#</a>
      </body></html>
    HTML

    parser = Myhtml::Parser.new
    parser.parse(str)
    parser.select_tags(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A).size.should eq 1
  end
end

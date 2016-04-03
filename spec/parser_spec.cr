require "./spec_helper"

describe Myhtml::Node do
  it "select_tags" do
    parser = Myhtml::Parser.new
    parser.parse("<html><body><div class=AAA style='color:red'>Haha</div>
      <div>blah</div>
      </body></html>")

    parser.count_tags(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV).should eq 2
    parser.count_tags(:div).should eq 2
    nodes = parser.select_tags(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV)
    nodes.size.should eq 2

    node1, node2 = nodes
    node1.child!.tag_text.should eq "Haha"
    node2.child!.tag_text.should eq "blah"

    nodes = parser.select_tags(:div)
    nodes.size.should eq 2
  end

  it "each_tag" do
    parser = Myhtml::Parser.new
    parser.parse("<html><body><div class=AAA style='color:red'>Haha</div>
      <div>blah</div>
      </body></html>")

    nodes = [] of Myhtml::Node
    parser.each_tag(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV) { |n| nodes << n }
    nodes.size.should eq 2

    node1, node2 = nodes
    node1.child!.tag_text.should eq "Haha"
    node2.child!.tag_text.should eq "blah"

    nodes = [] of Myhtml::Node
    parser.each_tag(:div) { |n| nodes << n }
    nodes.size.should eq 2
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
    parser.select_tags(:a).size.should eq 1
  end

  it "parse html with bom" do
    slice = Slice.new(3, 0_u8)
    slice[0] = 0xef.to_u8
    slice[1] = 0xbb.to_u8
    slice[2] = 0xbf.to_u8
    str = String.new(slice)
    str += "<html><head><title>1</title></head></html>"

    parser = Myhtml::Parser.new
    parser.parse(str)

    title = parser.head!.child!
    title.tag_name.should eq "title"
    title.child.try(&.tag_text).should eq "1"
  end
end

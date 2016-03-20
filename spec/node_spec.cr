require "./spec_helper"

describe Myhtml::Node do
  it "node from root" do
    parser = Myhtml::Parser.new
    parser.parse("<html><body><div class=AAA style='color:red'>Haha</div></body></html>")

    node = parser.root!.child!.next!.child!
    node.tag_name.should eq "div"
    node.attributes.should eq({"class" => "AAA", "style" => "color:red"})
    node.tag_id.should eq Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV
    node.child!.tag_text.should eq "Haha"
  end

  it "children" do
    parser = Myhtml::Parser.new
    parser.parse("<html><body><div class=AAA style='color:red'>Haha</div><span></span></body></html>")

    node = parser.root!.child!.next!
    node1, node2 = node.children
    node1.tag_name.should eq "div"
    node2.tag_name.should eq "span"
  end
end

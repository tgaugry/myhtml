require "./spec_helper"

describe Myhtml::Tree do
  describe "#create_node" do
    it "returns a new Myhtml::Node" do
      tree = Myhtml::Tree.new

      node = tree.create_node(:a)

      node.should be_a(Myhtml::Node)
      node.tag_id.should eq(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A)
    end
  end
end

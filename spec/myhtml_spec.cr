require "./spec_helper"

describe Myhtml do
  it "parser work" do
    parser = Myhtml::Parser.new("<html>BLA</html>")

    parser.root!.tag_name.should eq "html"
    parser.root!.child!.tag_name.should eq "head"
    parser.root!.child!.next!.tag_name.should eq "body"
    parser.root!.child!.next!.child!.tag_text.should eq "BLA"
  end

  it "version" do
    v = Myhtml.version_string
    v.size.should be > 0
  end

  it "decode_html_entities" do
    Myhtml.decode_html_entities("").should eq ""
    Myhtml.decode_html_entities(" ").should eq " "
    Myhtml.decode_html_entities("Chris").should eq "Chris"
    Myhtml.decode_html_entities("asdf &#61 &amp - &amp; bla -- &Auml; asdf").should eq "asdf = & - & bla -- Ä asdf"
  end

  context "parse_charset" do
    it { Myhtml.parse_charset("text/html; charset=utf-8").should eq Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT }
    # it { Myhtml.parse_charset("text/html; charset=unicode").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.parse_charset("text/html; charset=Windows-1251").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.parse_charset("text/html; charset=cp1251").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.parse_charset("text/html; charset='cp1251'").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.parse_charset("text/html; charset=\"cp1251\"").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.parse_charset("text/html; charset=euc-jp").should eq Myhtml::Lib::MyEncodingList::MyENCODING_EUC_JP }
    it { Myhtml.parse_charset("text/html; charset=").should eq nil }
    it { Myhtml.parse_charset("text/html").should eq nil }
  end
end

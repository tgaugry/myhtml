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

  context "detect_encoding_from_header" do
    it { Myhtml.detect_encoding_from_header("text/html; charset=utf-8").should eq Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT }
    it { Myhtml.detect_encoding_from_header("text/html; charset=O_o").should eq Myhtml::EncodingNotFound.new("O_o") }
    it { Myhtml.detect_encoding_from_header("text/html; charset=unicode").should eq Myhtml::EncodingNotFound.new("unicode") }
    it { Myhtml.detect_encoding_from_header("text/html; charset=Windows-1251").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.detect_encoding_from_header("text/html; charset=cp1251").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.detect_encoding_from_header("text/html; charset=cp-1251").should eq Myhtml::EncodingNotFound.new("cp-1251") }
    it { Myhtml.detect_encoding_from_header("text/html; charset='cp1251'").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.detect_encoding_from_header("text/html; charset=\"cp1251\"").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.detect_encoding_from_header("text/html; charset=euc-jp").should eq Myhtml::Lib::MyEncodingList::MyENCODING_EUC_JP }
    it { Myhtml.detect_encoding_from_header("text/html; charset=").should eq Myhtml::EncodingNotFound.new("") }
    it { Myhtml.detect_encoding_from_header("text/html").should eq Myhtml::EncodingNotFound.new("") }
    it { Myhtml.detect_encoding_from_header?("text/html").should eq nil }
    it { Myhtml.detect_encoding_from_header("asdfadsfaf r231 r8&(^(*^$&^%#s&^$&^%$^%$@$%%{!#$#$&^^*}&^").should eq Myhtml::EncodingNotFound.new("") }
  end

  context "detect_encoding_from_content_by_meta" do
    it { Myhtml.detect_encoding_from_content_by_meta(%q{<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />}).should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.detect_encoding_from_content_by_meta?(%q{<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />}).should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.detect_encoding_from_content_by_meta?(%q{<meta http-equiv="Content-Type" content="text/html; charset=" />}).should eq nil }
    it { Myhtml.detect_encoding_from_content_by_meta(%q{<meta http-equiv="Content-Type" content="text/html; charset=" />}).should eq Myhtml::EncodingNotFound.new("") }
    it { Myhtml.detect_encoding_from_content_by_meta?(%q{<meta http-equiv="Content-Type" content="text/html; charset=rtf" />}).should eq nil }
    it { Myhtml.detect_encoding_from_content_by_meta(%q{<meta http-equiv="Content-Type" content="text/html; charset=rtf" />}).should eq Myhtml::EncodingNotFound.new("rtf") }
  end

  context "detect_encoding" do
    it { Myhtml.detect_encoding?(PAGE25).should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml.detect_encoding?("abc" * 1000).should eq Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT }
    it { Myhtml.detect_encoding?("").should eq Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT }
  end
end

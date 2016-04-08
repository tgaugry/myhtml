# Example: extract only texts from html

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename)
      else
        <<-HTML
        <html>
          <br />
          <hr size="2" width="100%" />
          Название: <b>Что я сделал?</b><br />
          Ответил: <b>Чудище-Змей</b> на <b>21 Октябрь 2005, 18:11</b>
          <hr />
          <div style="margin: 0 5ex;">Давайте в этой теме говорить о том, что сегодня произошло</div>
          <br />
          <hr size="2" width="100%" />
          Название: <b>Что я сделал?</b><br />
          Ответил: <b>Rostik</b> на <b>21 Октябрь 2005, 18:15</b>
          <hr />
          <div style="margin: 0 5ex;"><b>Чудище-Змей</b>, а где ж ты успел получить, если увильнул?</div>
          <br />
        </html>
        HTML
      end

struct Char
  def blank?
    case ord
    when 9, 0xa, 0xb, 0xc, 0xd, 0x20, 0x85, 0xa0, 0x1680, 0x180e,
         0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006,
         0x2007, 0x2008, 0x2009, 0x200a, 0x2028, 0x2029, 0x202f,
         0x205f, 0x3000
      true
    else
      false
    end
  end
end

struct Myhtml::Node
  def textable?
    visible? && !object? && !is_tag_a? && !is_tag_noindex?
  end
end

def words(parser)
  parser
    .tags(:_text)                        # iterate through all TEXT nodes
    .select(&.parents.all?(&.textable?)) # select only which parents is visible good tag
    .map(&.tag_text)                     # mapping node text
    .reject(&.each_char.all?(&.blank?))  # reject blanked texts
    .map(&.strip.gsub(/\s{2,}/, " "))    # remove extra spaces
end

parser = Myhtml::Parser.new
parser.parse(str)
puts words(parser).join(" | ")

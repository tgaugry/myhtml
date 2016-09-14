# Example: extract only texts from html

require "../src/myhtml"
require "blank"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
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

struct Myhtml::Node
  def textable?
    visible? && !object? && !is_tag_a? && !is_tag_noindex?
  end
end

def words(parser)
  parser
    .nodes(:_text)                       # iterate through all TEXT nodes
    .select(&.parents.all?(&.textable?)) # select only which parents is visible good tag
    .map(&.tag_text)                     # mapping node text
    .reject(&.blank?)                    # reject blanked texts
    .map(&.strip.gsub(/\s{2,}/, " "))    # remove extra spaces
end

parser = Myhtml::Parser.new
parser.parse(str)
puts words(parser).join(" | ")

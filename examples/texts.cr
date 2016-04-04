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

def words(parser)
  w = [] of String
  parser.tags(:_text).each do |node|
    good_node = node.parents.all? do |node|
      node.visible? &&
        !node.object? &&
        !node.is_tag_a? &&
        !node.is_tag_noindex?
    end

    if good_node
      part = node.tag_text.strip
      w << part.gsub(/\s{2,}/, " ") unless part.empty?
    end
  end
  w
end

parser = Myhtml::Parser.new
parser.parse(str)
puts words(parser).join(" ")

# Example: normalize input html 
#   (close not closed tags, replace entities, downcase attributes & tags names)

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
          <html>
            <div>
            <span CLASS=bla>⬣ ⬤ ⬥ ⬦</div></span>
            <--->&
            asdf</BODY>
          </html>
        HTML
      end

puts Myhtml::Parser.new(str).root!.to_html

# Output:
#   <html><head></head><body><div>
#     <span class="bla">⬣ ⬤ ⬥ ⬦</span></div>
#     &lt;---&gt;&amp;
#     asdf
#   </body></html>

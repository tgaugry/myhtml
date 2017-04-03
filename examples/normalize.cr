# Example: normalize input html
#   (close not closed tags, replace entities, downcase attributes & tags names, remove comments)

require "../src/myhtml"

str = if filename = ARGV[0]?
        File.read(filename, "UTF-8", invalid: :skip)
      else
        <<-HTML
          <html>
            <div>
            <span CLASS=bla>⬣ ⬤ ⬥ ⬦</div></span>
            <--->&<!--bla-->
            asdf</BODY>
          </html>
        HTML
      end

myhtml = Myhtml::Parser.new(str, tree_options: Myhtml::Lib::MyhtmlTreeParseFlags::MyHTML_TREE_PARSE_FLAGS_SKIP_WHITESPACE_TOKEN)

myhtml.nodes(:_comment).each &.remove! # remove all comments

puts myhtml.root!.to_html

# Output:
#   <html><head></head><body><div><span class="bla">⬣ ⬤ ⬥ ⬦</span></div>
#      &lt;---&gt;&amp;
#          asdf</body></html>

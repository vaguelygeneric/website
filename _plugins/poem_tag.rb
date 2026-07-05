# A {% poem %}...{% endpoem %} block tag for quoting poetry in episode
# notes.
#
# This replaces hand-typed <blockquote>/<div>/<p> boilerplate with a
# small Liquid block so poems are just pasted in as plain text -- no
# markup to get wrong, and no dependency on CSS (`white-space:
# pre-wrap`) to preserve line breaks, which is what was silently
# collapsing poems into a single run-on line in podcast apps that
# don't load the site's stylesheet (their reader only sees the raw
# HTML that ships in the feed).
#
# Visually it renders as a title/byline "plate" (centered, hairline
# rules) framing a left-ruled "manuscript" body where the verse itself
# lives -- see .poem-header/.poem-body/.poem-footer in main.css.
#
# Usage:
#
#   {% poem title="Henry King, Who chewed bits of String, and was early
#      cut off in Dreadful Agonies." author="H. BELLOC"
#      source_title="Cautionary Tales for Children by Hilaire Belloc"
#      source_url="https://gutenberg.org/ebooks/27424" %}
#   The Chief Defect of Henry King
#   Was chewing little bits of String.
#
#   Physicians of the Utmost Fame
#   Were called at once; but when they came
#   {% endpoem %}
#
# Rules for the body:
#   - Blank-line-separated groups become stanzas, each its own <p>.
#   - Single newlines within a stanza become explicit <br> tags,
#     rather than relying on any CSS to preserve them.
#   - A stanza that's just one line starting with "## " (matching
#     Project Gutenberg's own convention for section headers, e.g.
#     "## MORAL") is rendered as a small bolded label instead of a
#     verse line, so text can be pasted straight from Gutenberg with
#     minimal cleanup.
#   - *italic* and **bold** are supported; everything else is
#     HTML-escaped, so stray &, <, > in pasted text can't break the
#     page.
#
# All attributes are optional. `title`/`author` are skipped if both
# are omitted; `source_title`/`source_url` are skipped if
# `source_title` is omitted (a `source_title` with no `source_url` is
# rendered as plain, unlinked footer text).
module Jekyll
  class PoemBlock < Liquid::Block
    ATTR_PATTERN = /(\w+)\s*=\s*"([^"]*)"/

    def initialize(tag_name, markup, tokens)
      super
      @attributes = {}
      markup.scan(ATTR_PATTERN) { |key, value| @attributes[key] = value }
    end

    def render(context)
      body = super
      title = @attributes["title"]
      author = @attributes["author"]
      source_title = @attributes["source_title"]
      source_url = @attributes["source_url"]

      html = +%(<blockquote class="poem">\n)

      if title || author
        html << %(  <div class="poem-header">\n)
        html << %(    <p class="poem-title">#{escape(title)}</p>\n) if title
        html << %(    <p class="poem-byline">#{escape(author)}</p>\n) if author
        html << %(  </div>\n)
      end

      html << %(  <div class="poem-body">\n)
      html << render_stanzas(body)
      html << %(  </div>\n)

      if source_title
        html << %(  <footer class="poem-footer">\n)
        if source_url
          html << %(    <a href="#{escape(source_url)}" target="_blank">#{escape(source_title)}</a>\n)
        else
          html << %(    #{escape(source_title)}\n)
        end
        html << %(  </footer>\n)
      end

      html << %(</blockquote>\n)
      html
    end

    private

    def render_stanzas(text)
      normalized = text.to_s.gsub("\r\n", "\n").strip
      return "" if normalized.empty?

      stanzas = normalized.split(/\n[ \t]*\n+/)

      stanzas.filter_map do |stanza|
        lines = stanza.split("\n").map(&:strip).reject(&:empty?)
        next nil if lines.empty?

        if lines.length == 1 && lines.first.start_with?("## ")
          heading = lines.first.sub(/^##\s*/, "")
          %(    <p class="poem-heading"><strong>#{format_line(heading)}</strong></p>\n)
        else
          rendered = lines.map { |line| format_line(line) }.join("<br>\n      ")
          %(    <p>\n      #{rendered}\n    </p>\n)
        end
      end.join
    end

    def format_line(line)
      apply_emphasis(escape(line))
    end

    def escape(str)
      str.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
    end

    def apply_emphasis(str)
      str.gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
         .gsub(/(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)/, '<em>\1</em>')
    end
  end
end

Liquid::Template.register_tag("poem", Jekyll::PoemBlock)

require "torture/snippet"

# Snippets.new(root: ..., file: ...)
#   {Cell@model} is options
#
class Snippets < Cell::ViewModel
  # self.view_paths = ["./2.1"]
  include Cell::Erb
  # include Cell::Development

  # def extract(section, root:, file:, collapse: nil, unindent: true)
  def extract(section, **options)
    options = @model.merge(collapse: nil, unindent: true, **options)

    Torture::Snippet.extract_from(file: File.join(options[:root], options[:file]), marker: section, collapse: options[:collapse], unindent: options[:unindent])
  end

  def code(*args)
    dont_extract = @model[:extract]===false
    code = ""

    if block_given? # TODO: test me!!!
      dont_extract = true
      code = yield.chomp
    end

    code = dont_extract ? code : extract(*args)

    %{<pre><code class="ruby light code-snippet wow fadeIn">
#{code}</code></pre>}
  end

  def show(snippet:, path:)
    content = render(view: "#{snippet}.md", prefixes: [path])

    content
  end

  def initialize(headers:, **options)
    super

    @headers = headers
  end

  # TODO: make library call
  private def header_for(title, permalink, level)
    top_header = @headers[level-1].last
    raise title unless top_header

    @headers[level] << header = Torture::Toc::Header(level, title, permalink, top_header)
    top_header.items << header

    return header, top_header
  end
  private def render_header(html)
    %{<span class="divider"></span>

#{html}}
  end

  # 1 header_for
  # 2 template = <a>{bla}
  # 3 parse_template (Cell.render template, options{id: header.id, title: title, ...})
  # 4 render_header

  # Currently called "book".
  def h2(title, permalink: title, name: title, level:2, display_title: title, **)
    header, top_header = header_for(title, permalink, level)

    header = %{<h#{level} id="#{header.id}">#{display_title}</h#{level}> <!-- {#{header.id}-toc} -->}

    render_header(header)
  end

  # Currently called "chapter".
  def h3(title, **options)
    h2(title, level: 3, **options)
  end

  def h4(title, permalink: title, level:4, **options) # FIXME: test me.
    header, top_header = header_for(title, permalink, level)

    breadcrumb = %{<ul class="navigation">
    <li>#{top_header.title}</li>
    <li id="#{header.id}">#{title}</li>
</ul>
}
    render_header(breadcrumb)
  end



  def img(path)
    %{<img src="/images/#{path}" class="mx-auto d-block">}
  end

  def info(&block)
    %{<div class="bd-callout bd-callout-info">#{Kramdown::Document.new(yield).to_html}</div>}
  end
end

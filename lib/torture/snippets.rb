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
    %{<pre><code class="ruby light code-snippet wow fadeIn">
#{extract(*args)}</code></pre>}
  end

  def show(snippet:, path:)
    content = render(view: "#{snippet}.md", prefixes: [path])

    content
  end

  def initialize(h1:, **options)
    super


# FIXME: top header, where does it come from?
    @headers = {1 => [h1], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.
  end

  # Currently called "book".
  def h2(title, name: title, level:2, display_title: title, html:nil, **)
    top_header = @headers[level-1].last
    raise title unless top_header

    @headers[level] << header = Torture::Toc::Header(title, level, top_header)
    top_header.items << header

    header = html || %{<h#{level} id="#{header.id}">#{display_title}</h#{level}> <!-- {#{header.id}-toc} -->}

    %{<span class="divider"></span>

#{header}}
  end

  # Currently called "chapter".
  def h3(title, **options)
    h2(title, level: 3, **options)
  end

  def h4(title, level:4, **options)
    top_header = @headers[level-1].last

    breadcrumb = %{<ul class="navigation" id="">
    <li>#{top_header.title}</li>
    <li>#{title}</li>
</ul>
}

    h2(title, html: breadcrumb, level: level, **options)
  end



  def img(path)
    %{<img src="/images/#{path}" class="mx-auto d-block">}
  end

  def info(&block)
    %{<div class="bd-callout bd-callout-info">#{Kramdown::Document.new(yield).to_html}</div>}
  end
end

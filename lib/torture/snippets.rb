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

  def code(*args, **kws)
    dont_extract = @model[:extract]===false
    code = ""

    if block_given? # TODO: test me!!!
      dont_extract = true
      code = yield.chomp
    end

    code = dont_extract ? code : extract(*args, **kws)
    Kramdown::Document.new("\n\t#{code.gsub("\n", "\n\t")}").to_html
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
  private def header_for(title, level, **options)
    top_header = @headers[level-1].last
    raise title unless top_header

    @headers[level] << header = Torture::Toc::Header(title, level, top_header, **options)
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
  def h2(title, name: title, level:2, display_title: title, **)
    header, top_header = header_for(title, level)

    header = %{<h#{level} id="#{header.id}">#{display_title}</h#{level}> <!-- {#{header.id}-toc} -->}

    render_header(header)
  end

  # Currently called "chapter".
  def h3(title, **options)
    h2(title, level: 3, **options)
  end

  def h4(title, level:4, **options) # FIXME: test me.
    header, top_header = header_for(title, level, **options)

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

  # nav_tabs do |tab|
  #   tab.(title: 'dry-validation', active: true) do
  #     <%= code '...' %>
  #   end
  #
  #   tab.(title: 'ActiveModel') do
  #     <%= code '...' %>
  #   end
  # end
  def nav_tabs(&block)
    caller_location = caller_locations.first
    id = "#{caller_location.absolute_path}-#{caller_location.lineno}"

    NavTabs.(id, tabs: [], contents: [], &block)
  end

  module NavTabs
    module_function

    def call(id, tabs:, contents:, &block)
      # Yield `tab` to `nav_tabs` helper here, which is used to accept tab content.
      # Calling `block` fills `tabs` and `contents` array.
      block.call tab_proc(tabs, contents, parent: id)

      Array[
        content_for(:ul, id: id, class: 'nav nav-tabs') { tabs.join },
        content_for(:div, class: 'tab-content') { contents.join }
      ].join
    end

    def tab_proc(tabs, contents, parent:)
      ->(title:, active: false, **tab_options, &content_block) do
        target = "#{parent}-#{title}".gsub(/[^a-z0-9\-_]+/i, '-')

        tabs << tab(title: title, target: target, active: active, parent: parent, **tab_options)
        contents << content(target: target, active: active, &content_block)
      end
    end

    def tab(title:, target:, parent:, toggle: :tab, active:)
      klass = "nav-link pink #{active ? 'active active' : ''}"

      content_for(:li, class: 'nav-item') do
        content_for(:a, href: '#', class: klass, 'data-toggle': toggle, 'data-tag': "##{target}") do
          title
        end
      end
    end

    def content(target:, active: false, &block)
      content_for(:div, id: target, class: "tab-pane fade show #{active ? 'active' : ''}") do
        Kramdown::Document.new(block.call).to_html
      end
    end

    def content_for(tag, **args)
      attributes = args.map{ |attr, value| "#{attr}=\"#{value}\"" }.join(' ')
      %{<#{tag} #{attributes}> #{yield if block_given?} </#{tag}>}
    end
  end
end

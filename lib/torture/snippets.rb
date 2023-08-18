require "torture/snippet"

# Snippets.new(root: ..., file: ...)
#   {Cell@model} is options
#
class Snippets < Cell::ViewModel
  # self.view_paths = ["./2.1"]
  include Cell::Erb
  # include Cell::Development

  def show(snippet:, path:)
    content = render(view: "#{snippet}.md", prefixes: [path])

    content
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
# FIXME: untested.
  def nav_tabs(id: rand, &block)
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

module Torture
  module Page
    class HTML < Cell::ViewModel
      include Cell::Erb
      # include Cell::Layout::External
      def render_layout(name, options, content)
        content = Kramdown::Document.new(content).to_html

        super(name, options, content)
      end

      def page(options) # done via `Options`.
        @options = options
        ""
      end

      def show(page:, path:, layout:)
        @path = path # FIXME

        html = render(view: page, prefixes: [path], layout: layout)
      end

      def call(*)
        return super, @graph
      end

      # FIXME: do we need that?
      Graph = Struct.new(:level_to_header, :page_header) do
      end

      # Render all snippets in one page. This is called within activity.md.erb, for example.
      def snippets(options)
        page_header = Torture::Toc.Header(title, 1, {id: nil}) # FIXME: remove mutability.

        level_to_header = {}

        page = options.collect do |snippet_name, _options|
          _options = _options.merge(h1: page_header)

          cell = Snippets.new(**_options)


          html = cell.(:show, snippet: snippet_name, path: @path)
          headers = cell.instance_variable_get(:@headers)

          level_to_header = Torture.merge_toc(level_to_header, headers)

          html
        end


        # TOC per page:
        @graph = Graph.new(level_to_header, page_header)

        page.join("\n")
      end

      def toc
        %{<%= table_of_content %>}
      end
      def right_sidebars
        %{<%= right_sidebars %>}
      end

      def h2(title)
        %{<h2>#{title}</h2>}
      end

    # layout
      # TODO: should layout be a separate cell?
      def title
        @options[:title] or raise "No <%= page %> call in #{self}"
      end
      # def layout
      #   @options[:layout] or raise
      # end
    end

    class Final < Cell::ViewModel
      def show(html:, **locals)
        render view: html, locals: {**locals}
      end

      def find_template(view:, **, &block)
        template = Tilt::ERBTemplate.new { view }
      end
    end
  end
end

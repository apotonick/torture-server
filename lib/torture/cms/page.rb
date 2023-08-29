module Torture
  module Cms

    class Page

      def render_page(title:, sections:, target_url:, **options)
        page_header = Torture::Toc.Header(title, 1, {id: nil}, target: target_url) # FIXME: remove mutability.

        headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.

        ["<h1>#{title}</h1>\n"] + # FIXME

        # generate section
        html_sections = sections.collect do |file_name, section_options|
          html, result = render_section(**options, **section_options, file_name: file_name, headers: headers)

          headers = result.to_h[:headers] # TODO: additional step!

          html
        end

        sections_html = html_sections.join("\n")

        options.merge(
          content:      sections_html,
          headers:      headers,
        )
      end

      def render_section(file_name:, section_dir:, headers:, snippet_dir:, snippet_file:, section_cell:, section_cell_options:, kramdown_options: {}, **)
        template_file = File.join(section_dir, file_name) # "test/cms/snippets/reform/intro.md.erb"
        template      = Cell::Erb::Template.new(template_file)

        section_cell_instance = section_cell.new(
          headers: headers,

          # for {code}
          root: snippet_dir,
          file: snippet_file,
          **section_cell_options
        )

        # html = Torture::Cms::Section.({template: template, exec_context: section_cell_instance})
        # html = Torture::Cms::Section.(template: template, exec_context: section_cell_instance)
        result = ::Cell.({template: template, exec_context: section_cell_instance})

        html = result.to_s

        convert_method = kramdown_options[:converter] || :to_html

        html = Kramdown::Document.new(html, kramdown_options).send(convert_method)

        return html, result
      end
    end
  end
end


require "fileutils"



module Torture
  module Cms

    class Page

      def render_page(title:, section_cell:, section_cell_options:, section_dir:, snippet_dir:, target_file:, kramdown_options:, layout: {}, **sections)
        page_header = Torture::Toc.Header(title, 1, {id: nil}) # FIXME: remove mutability.
        headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.


        level_to_header = {}
        # TODO: version "slug"

        ["<h1>#{title}</h1>\n"] + # FIXME

        # generate section
        html_sections = sections.collect do |file_name, options|
          html, result = render_section(section_cell: section_cell, section_cell_options: section_cell_options, file_name: file_name, section_dir: section_dir, snippet_dir: snippet_dir, headers: headers,
            kramdown_options: kramdown_options, **options)

# TODO: additional step
          level_to_header = Torture.merge_toc(level_to_header, result.to_h[:headers]) # FIXME: this should be optional!
# TODO: additional step

          html
        end

        sections_html = html_sections.join("\n")

        if layout.any? # FIXME: only add when needed.
          result = ::Cell.({template: layout[:template]}) { sections_html }
          sections_html = result.to_s
        end

        create_file(target_file: target_file, content: sections_html)
      end

      def render_section(file_name:, section_dir:, headers:, snippet_dir:, snippet_file:, section_cell:, section_cell_options:, kramdown_options:)
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

      def create_file(target_file:, content:)
        dir = File.dirname(target_file)
        FileUtils.mkdir_p(dir) # TODO: test that properly.

        File.open(target_file, "w") { |file| file.write(content) }
      end
    end
  end
end


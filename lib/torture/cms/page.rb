require "fileutils"



module Torture
  module Cms

    class Page

      def render_page(title:, section_cell:, section_cell_options:, section_dir:, snippet_dir:, target_file:, kramdown_options:, **sections)
        page_header = Torture::Toc.Header(title, 1, {id: nil}) # FIXME: remove mutability.
        headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.


        level_to_header = {}
        # TODO: version "slug"

        ["<h1>#{title}</h1>\n"] + # FIXME

        # generate section
        html_sections = sections.collect do |file_name, options|
          render_section(section_cell: section_cell, section_cell_options: section_cell_options, file_name: file_name, section_dir: section_dir, snippet_dir: snippet_dir, headers: headers,
            kramdown_options: kramdown_options, **options)

          # level_to_header = Torture.merge_toc(level_to_header, headers)
        end

        create_file(target_file: target_file, content: html_sections.join("\n"))
      end

      def render_section(file_name:, section_dir:, headers:, snippet_dir:, snippet_file:, section_cell:, section_cell_options:, kramdown_options:)
        template_file = File.join(section_dir, file_name) # "test/cms/snippets/reform/intro.md.erb"
        template      = Cell::Erb::Template.new(template_file)

        section_cell = section_cell.new(
          headers: headers,

          # for {code}
          root: snippet_dir,
          file: snippet_file,
          **section_cell_options
        )

        html = Torture::Cms::Section.({template: template, exec_context: section_cell})

        html = Kramdown::Document.new(html, kramdown_options).to_html
      end

      def create_file(target_file:, content:)
        dir = File.dirname(target_file)
        FileUtils.mkdir_p(dir) # TODO: test that properly.

        File.open(target_file, "w") { |file| file.write(content) }
      end
    end
  end
end


module Torture
  module Cms
    class Page

      def render_page(title:, section_cell:, section_dir:, snippet_dir:, **sections)
        page_header = Torture::Toc.Header(title, 1, {id: nil}) # FIXME: remove mutability.
        headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.


        # TODO: version "slug"

        sections.collect do |file_name, options|
          render_section(section_cell: section_cell, file_name: file_name, section_dir: section_dir, snippet_dir: snippet_dir, headers: headers, **options)
        end

# generate section


    # html = Torture::Cms::Section.({template: template, exec_context: section_cell})
      end

      def render_section(file_name:, section_dir:, headers:, snippet_dir:, snippet_file:, section_cell:)
        template_file = File.join(section_dir, file_name) # "test/cms/snippets/reform/intro.md.erb"
        template      = Cell::Erb::Template.new(template_file)

        section_cell = section_cell.new(
          headers: headers,

          # for {code}
          root: snippet_dir,
          file: snippet_file
        )

        html = Torture::Cms::Section.({template: template, exec_context: section_cell})
      end
    end
  end
end


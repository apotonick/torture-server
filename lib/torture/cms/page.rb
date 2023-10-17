module Torture
  module Cms

    class Page # TODO: rename to {render_sections}
      def render_page(title:, sections:, target_url:, toc_left: true, **options)
        # NOTE: this is the real local version title, not the {:toc_title}.
        page_header = Torture::Toc.Header(title, 1, {id: nil}, target: target_url, visible: toc_left) # FIXME: remove mutability.

        headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.

        ["<h1>#{title}</h1>\n"] + # FIXME

        # generate section
        sections = sections.collect do |file_name, section_options|
          html, result, options_from_section = render_section(**options, **section_options, file_name: file_name, headers: headers)


          headers = result.to_h[:headers] # TODO: additional step!

          {
            content: html,
            options: options_from_section,
          }
        end

        sections_html = sections.collect { |section| section[:content] }.join("\n")

        options.merge(
          title: title,
          content:      sections_html,
          headers:      headers,
          sections:     sections,
        )
      end

      def render_section(file_name:, section_dir:, headers:, snippet_dir:, snippet_file:, section_cell:, section_cell_options:, kramdown_options: {}, **)
        template_filename = File.join(section_dir, file_name) # "test/cms/snippets/reform/intro.md.erb"
        template = Cell::Erb::Template.new(template_filename)

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

        return html, result, {file_name: template_filename}
      end

      # Generic entrypoint for rendering a particular cell.
      def self.render_cell(ctx, context_class:, template:, options_for_cell:, **)
        options_for_cell, block = normalize_cell_arguments(**options_for_cell)

        cell_instance = context_class.new(**options_for_cell)

        result = ::Cell.({template: template, exec_context: cell_instance}) { block }

        ctx[:content] = result.to_s
      end

      def self.normalize_cell_arguments(yield_block: nil, **options_for_cell)
        return options_for_cell, yield_block
      end

      class Render < Trailblazer::Activity::Railway
        class WithToc < Trailblazer::Activity::Railway
          step :compile_level_1_headers # FIXME.

          def compile_level_1_headers(ctx, book:, h1_headers:, **)
            ctx[:level_1_headers] = Helper::Toc::Versioned.collapsable(h1_headers, expanded: book) # "view model" for {toc_left}.
          end
        end
      end
    end
  end
end


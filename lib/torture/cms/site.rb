require "fileutils"

module Torture
  module Cms
    class Site
      def render_pages(pages, **site_options)

        pages = pages.collect do |name, versions| # TODO: extract me!
          [
            name,
            render_versioned_pages(**site_options, versions: versions, title: name)
          ]
        end.to_h


      # TODO: additional step
      #       headers
        headers =
          pages.collect do |book, versions|
            versions =
              versions.collect do |version, options|
                h1 = options[:headers][1] || raise

                [version, h1]
              end.to_h

            [book, versions]
          end

      # TODO: additional step
      #       layout
        pages_by_version =
          pages.collect do |book, versions|
            versions.collect do |version, options|
              layout = options[:layout]

              if layout.is_a?(Hash) # FIXME: only add when needed.
                level_1_headers = Helper::Toc::Versioned.collapsable(headers, expanded: book)

                pp level_1_headers

                left_toc_options = layout[:left_toc]
                left_toc_cell = left_toc_options[:cell].new(headers: level_1_headers, current_page: nil)

                left_toc_html = ::Cell.({template: left_toc_options[:template], exec_context: left_toc_cell})

                layout_cell_instance = layout[:cell].new(left_toc_html: left_toc_html)

                sections_html = options[:content]

                result = ::Cell.({template: layout[:template], exec_context: layout_cell_instance}) { sections_html }

                [version, options.merge(content: result.to_s)]
              else
                [version, options]
              end
            end
          end
      end

      def render_versioned_pages(versions:, **site_options)
        versions.collect do |version, version_options|
          result = render_page(**site_options, sections: version_options[:sections], **version_options[:options])

          [
            version,
            result
          ]
        end.to_h
      end

      def produce_versioned_pages(**options)
        pages = render_versioned_pages(**options)

        pages.collect do |version, page_options|
          produce_page(**page_options)
        end
      end

      def render_page(**options)
        Torture::Cms::Page.new.render_page(**options)
      end

      def produce_page(**options)
        create_file(**options)
      end

      def create_file(target_file:, content:, **)
        dir = File.dirname(target_file)
        FileUtils.mkdir_p(dir) # TODO: test that properly.

        File.open(target_file, "w") { |file| file.write(content) }
      end
    end
  end
end

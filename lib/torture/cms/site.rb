require "fileutils"

module Torture
  module Cms
    class Site
      def render_pages(pages, **site_options)

        # Render only the concated sections per page.
        pages = pages.collect do |name, book_options|
          [
            name,
            render_versioned_book(**site_options, name: name, **book_options)
          ]
        end.to_h

      # TODO: additional step
      #       headers
        h1_headers =
          pages.collect do |name, versions|
            versions =
              versions.collect do |version, options|
                h1 = options[:headers][1][0] || raise
                h1 = h1.dup
                h1.title = options[:toc_title] # set the "sidebar title" on this header.

                [version, [h1]]
              end.to_h

            [name, versions]
          end

      # TODO: additional step
        page_file_map = pages.flat_map do |name, versions|
          versions.flat_map  do |version, options|
            options[:sections].collect { |section| [section[:options][:file_name], [name, version]] }
          end
        end.to_h

        # pp page_file_map

      # TODO: additional step
      #       layout
      # Render the actual page with TOC.
        pages_by_version =
          pages.collect do |book, versions|
            versions.collect do |version, options|
              # layout = options[:layout]
              ctx = render_final_page(book, h1_headers: h1_headers, **options)

              [version, options.merge(content: ctx[:content])]
            end
          end

        return pages_by_version, {file_to_page_map: page_file_map, h1_headers: h1_headers} # TODO: return values, test.
      end

      def render_final_page(book, render:, h1_headers:, **options)
        # FIXME: move to render activity!
        level_1_headers = Helper::Toc::Versioned.collapsable(h1_headers, expanded: book) # "view model" for {toc_left}.

                                                # Render
        signal, (ctx, _) = Trailblazer::Activity.(render, {level_1_headers: level_1_headers, **options})

        return ctx
      end

      def render_versioned_book(versions:, **site_options)
        versions.collect do |version, version_options|
          result = render_page(**site_options, sections: version_options[:sections], **version_options[:options])

          [
            version,
            result
          ]
        end.to_h
      end

      def produce_versioned_pages(pages, **options)
        pages, returned = render_pages(pages, **options)

        artifacts =
          pages.collect do |versions|
            versions.collect do |version, _options|
              produce_page(**_options)
            end
          end

        return artifacts, returned # FIXME: test.
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

        File.open(target_file, "w+") { |file| file.write(content) } # TODO: test w+ override
      end
    end
  end
end

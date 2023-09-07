require "fileutils"

module Torture
  module Cms
    class Site
      def render_pages(pages, **site_options)

        pages = pages.collect do |name, book_options|
          [
            name,
            render_versioned_book(**site_options, name: name, **book_options)
          ]
        end.to_h

      # TODO: additional step
      #       headers
        headers =
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
      #       layout
      # Render the actual page with TOC.
        pages_by_version =
          pages.collect do |book, versions|
            versions.collect do |version, options|
              # layout = options[:layout]
              render_activity = options[:render] || raise

              level_1_headers = Helper::Toc::Versioned.collapsable(headers, expanded: book) # "view model" for {toc_left}.

                                                      # Render
              signal, (ctx, _) = Trailblazer::Activity.(render_activity, {level_1_headers: level_1_headers, **options})

              [version, options.merge(content: ctx[:content])]
            end
          end
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
        pages = render_pages(pages, **options)

        pages.collect do |versions|
          versions.collect do |version, _options|
            produce_page(**_options)
          end
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

        File.open(target_file, "w+") { |file| file.write(content) } # TODO: test w+ override
      end
    end
  end
end

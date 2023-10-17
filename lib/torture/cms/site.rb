require "fileutils"

module Torture
  module Cms
    class Site
      def render_pages(pages, site_render: Trb, **site_options)
        signal, (ctx, _) = site_render.invoke([{pages: pages, **site_options}, {}])

        return ctx[:pages], {file_to_page_map: ctx[:page_file_map], h1_headers: ctx[:h1_headers]}
      end

      def self.render_pages_(ctx, pages:, toc: true, **site_options) # FIXME: fix toc
        # Render only the concated sections per page.
        pages = pages.collect do |name, book_options|
          [
            name,
            render_versioned_book(**site_options, name: name, **book_options)
          ]
        end.to_h

        ctx[:pages] = pages
      end

      # We need to do that on all pages.
      def self.extract_h1_headers(ctx, pages:, **)
      # TODO: additional step
      #       headers
        h1_headers =
          pages.collect do |name, versions|
            next if versions.first[1][:toc] == false # FIXME: somehow, this TOTALLY sucks. # TODO: test me

            versions =
              versions.collect do |version, options|
                h1 = options[:headers][1][0] || raise
                h1 = h1.dup
                h1.title = options[:toc_title] # set the "sidebar title" on this header.

                [version, [h1]]
              end.to_h

            [name, versions]
          end
            .compact # this sucks, we need that for {toc: false}

        ctx[:h1_headers] = h1_headers
      end

      def self.page_file_map(ctx, pages:, **)
      # TODO: additional step
        page_file_map = pages.flat_map do |name, versions|
          versions.flat_map  do |version, options|
            options[:sections].collect { |section| [section[:options][:file_name], [name, version]] }
          end
        end.to_h

        ctx[:page_file_map] = page_file_map
      end

        # pp page_file_map

      def self.render_final_pages(ctx, pages:, h1_headers:, **)
      # TODO: additional step
      #       layout
      # Render the actual page with TOC.
        pages_by_version =
          pages.collect do |book, versions|
            versions.collect do |version, options|
              # layout = options[:layout]
              _ctx = render_final_page(book, h1_headers: h1_headers, **options)

              [version, options.merge(content: _ctx[:content])]
            end
          end

        ctx[:pages] = pages_by_version
      end

      def self.render_final_page(book, render:, **options)
                                                # Render
        signal, (ctx, _) = Trailblazer::Activity.(render, {book: book, **options})

        return ctx
      end

      def self.render_versioned_book(versions:, **site_options)
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

      def self.render_page(**options)
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

      class Trb < Trailblazer::Activity::Railway # FIXME: move.
        step Site.method(:render_pages_)
        step Site.method(:extract_h1_headers)
        step Site.method(:page_file_map)
        step Site.method(:render_final_pages)
      end

    end
  end
end

require "fileutils"

module Torture
  module Cms
    class Site
      def self.render_pages(pages, site_render: Trb, **site_options)
        signal, (ctx, _) = site_render.invoke([{pages: pages, **site_options}, {}])

        return ctx[:pages], {file_to_page_map: ctx[:page_file_map], book_headers: ctx[:book_headers]}
      end

      def self.render_pages_(ctx, pages:, **site_options)
        # Render only the concated sections per page.
        pages = pages.collect do |name, book_options|
          [
            name,
            render_versioned_book(**site_options, name: name, **book_options)
          ]
        end.to_h

        # pp site_options[:book_headers]
        ctx[:pages] = pages
      end

      module Header
        # Header for left toc.
        Book = Struct.new(:name, :toc_title, :versions_to_h2_headers, :include_in_toc, :options) do
          def default_version
            versions_to_h2_headers.keys[0]
          end
        end

        module Extract
          module_function

          # At this point, we don't have any h2 headers, yet.
          # This is before we render actual pages and collect h[2,3,4] headers.
          def compute_book_headers(ctx, pages:, **)
            book_headers =
              pages.collect do |name, options|

                _versions =
                  options[:versions].collect do |version, version_options|
                    title       = version_options[:options][:title]
                    target_url  = version_options[:options][:target_url]

                    page_header = Torture::Toc.Header(title, 1, {id: nil}, target: target_url, options_for_toc: version_options[:options][:options_for_toc]) # FIXME: remove mutability.

                    [version, page_header]
                  end
                  .to_h

                # DISCUSS: different "layer"
                toc_title       = options.fetch(:toc_title)
                include_in_toc  = options[:include_in_toc]

                book_header = Book.new(
                  name,
                  toc_title,
                  _versions,
                  include_in_toc,
                )

                [name, book_header]
              end
              .to_h

            ctx[:book_headers] = book_headers
          end
        end
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

      def self.render_final_pages(ctx, pages:, book_headers:, **)
      # TODO: additional step
      #       layout
      # Render the actual page with TOC.
        pages_by_version =
          pages.collect do |book, versions|
            versions.collect do |version, options|
              # layout = options[:layout]
              _ctx = render_final_page([book, version], headers: book_headers, **options)

              [version, options.merge(content: _ctx[:content])]
            end
          end

        ctx[:pages] = pages_by_version
      end

      def self.render_final_page(book_version, render:, **options)

                                                # Render
        signal, (ctx, _) = Trailblazer::Activity.(render, {book_version: book_version, **options})

        return ctx
      end

      def self.render_versioned_book(versions:, **site_options)
        versions.collect do |version, version_options|

          result = render_page(**site_options, sections: version_options[:sections], version: version, **version_options[:options])

          [
            version,
            result
          ]
        end.to_h
      end

      def self.produce_versioned_pages(pages, **options)
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

      def self.produce_page(**options)
        create_file(**options)
      end

      def self.create_file(target_file:, content:, **)
        dir = File.dirname(target_file)
        FileUtils.mkdir_p(dir) # TODO: test that properly.

        File.open(target_file, "w+") { |file| file.write(content) } # TODO: test w+ override
      end

      class Trb < Trailblazer::Activity::Railway # FIXME: move.
        step Site::Header::Extract.method(:compute_book_headers)
        step Site.method(:render_pages_)
        step Site.method(:page_file_map)
        step Site.method(:render_final_pages)
      end

    end
  end
end

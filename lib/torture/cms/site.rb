require "fileutils"

module Torture
  module Cms
    class Site
      def render_versioned_pages(title:, section_cell:, section_cell_options:, kramdown_options: {}, layout: {}, **versions)
        versions.collect do |version, options|
          [
            version,
            render_page(title: title, section_cell: section_cell, section_cell_options: section_cell_options, kramdown_options: kramdown_options, layout: layout, **options)
          ]
        end
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

      def create_file(target_file:, content:)
        dir = File.dirname(target_file)
        FileUtils.mkdir_p(dir) # TODO: test that properly.

        File.open(target_file, "w") { |file| file.write(content) }
      end
    end
  end
end

module Torture
  module Cms
    class Site
      def render_versioned_pages(title:, section_cell:, **versions)
        versions.collect do |version, options|
          [
            version,
            render_page(title: title, section_cell: section_cell, **options)
          ]
        end
      end

      def render_page(**options)
        Torture::Cms::Page.new.render_page(**options)
      end
    end
  end
end

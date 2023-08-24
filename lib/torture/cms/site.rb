module Torture
  module Cms
    class Site
      def render_versioned_pages(title:, section_cell:, section_cell_options:, kramdown_options: {}, **versions)
        versions.collect do |version, options|
          [
            version,
            render_page(title: title, section_cell: section_cell, section_cell_options: section_cell_options, kramdown_options: kramdown_options, **options)
          ]
        end
      end

      def render_page(**options)
        Torture::Cms::Page.new.render_page(**options)
      end
    end
  end
end

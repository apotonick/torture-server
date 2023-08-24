module Torture
  module Cms
    # Helpers are for cells!
    module Helper
      module Header
        # 1 header_for
        # 2 template = <a>{bla}
        # 3 parse_template (Cell.render template, options{id: header.id, title: title, ...})
        # 4 render_header

        # Currently called "book".
        def h2(title, name: title, level: 2, display_title: title, classes: "", **) # FIXME: classes not tested and sucks.
          header, top_header = header_for(title, level)

          # header = %{<h#{level} id="#{header.id}">#{display_title}</h#{level}> <!-- {#{header.id}-toc} -->}


          render_header(header: header, level: level, display_title: display_title, classes: classes)
        end

        # Currently called "chapter".
        def h3(title, classes: "", **options)
          header, top_header = header_for(title, 3, **options)

          render_header(header: header, display_title: title, level: 3, classes: classes, **options)
        end

        def h4(title, level: 4, classes: "", **options) # FIXME: test me.
          header, top_header = header_for(title, level, **options)

          return           breadcrumb = %(<h4 class="#{classes}">#{top_header.title} / #{title}</h4> )


          breadcrumb = %{<ul class="navigation">
          <li>#{top_header.title}</li>
          <li id="#{header.id}">#{title}</li>
      </ul>
      }
          return breadcrumb
          render_header(breadcrumb)
        end

        private def header_for(title, level, **options)
          top_header = @options[:headers][level-1].last
          raise title unless top_header

          @options[:headers][level] << header = Torture::Toc::Header(title, level, top_header, **options)
          top_header.items << header

          return header, top_header
        end

        private def render_header(header:, level:, display_title:, classes:)
          header = %{<h#{level} id="#{header.id}" class="#{classes}">#{display_title}</h#{level}>}
          # return html
        end
      end
    end
  end
end

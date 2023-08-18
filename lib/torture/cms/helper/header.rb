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
        def h2(title, name: title, level: 2, display_title: title, **)
          header, top_header = header_for(title, level)

          header = %{<h#{level} id="#{header.id}">#{display_title}</h#{level}> <!-- {#{header.id}-toc} -->}

          render_header(header)
        end

        # Currently called "chapter".
        def h3(title, **options)
          h2(title, level: 3, **options)
        end

        def h4(title, level: 4, **options) # FIXME: test me.
          header, top_header = header_for(title, level, **options)

          breadcrumb = %{<ul class="navigation">
          <li>#{top_header.title}</li>
          <li id="#{header.id}">#{title}</li>
      </ul>
      }
          render_header(breadcrumb)
        end

        private def header_for(title, level, **options)
          top_header = @options[:headers][level-1].last
          raise title unless top_header

          @options[:headers][level] << header = Torture::Toc::Header(title, level, top_header, **options)
          top_header.items << header

          return header, top_header
        end

        private def render_header(html)
          %{<span class="divider"></span>

      #{html}}
        end
      end
    end
  end
end

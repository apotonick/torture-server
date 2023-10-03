module Torture
  module Cms
    # Helpers are for cells!
    module Helper
      module Header
        # 1 header_for!
        # 2 template = <a>{bla}
        # 3 parse_template (Cell.render template, options{id: header.id, title: title, ...})
        # 4 render_header

        # Currently called "book".
        def h2(title, level: 2, **options)
          header_for(title: title, level: level, **options)
        end

        # Currently called "chapter".
        def h3(title, level: 3, **options)
          header_for(title: title, level: level, **options)
        end

        def h4(title, level: 4, **options)
          header_for(title: title, level: level, **options)
        end

        def header_for(render: Render, title:, classes: "", **options)
          signal, (ctx, _) = Trailblazer::Activity.(render, headers: @options[:headers], display_title: title, title: title, classes: classes, **options)

          ctx[:html]
        end

        def self.header_for!(ctx, title:, level:, headers:, **options)
          top_header = headers[level-1].last
          raise title unless top_header

          headers[level] << header = Torture::Toc::Header(title, level, top_header, **options)
          top_header.items << header

          ctx[:header]        = header
          ctx[:parent_header] = top_header
        end

        def self.render_header(ctx, header:, level:, display_title:, classes:, **)
          ctx[:html] = %{<h#{level} id="#{header.id}" class="#{classes}">#{display_title}</h#{level}>}
        end

        class Render < Trailblazer::Activity::Railway
          step Header.method(:header_for!),   id: :create_header!
          step Header.method(:render_header), id: :render_header
        end
      end
    end
  end
end

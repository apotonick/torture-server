module Torture
  module Cms
    class Page

         title = "Reform"
      def render_page(title:)

    page_header = Torture::Toc.Header(title, 1, {id: nil}) # FIXME: remove mutability.
    headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.


    # TODO: version "slug"

# generate section
    template = Cell::Erb::Template.new("test/cms/snippets/reform/intro.md.erb")

    section_cell = My::Cell::Section.new(
      headers: headers,

      # for {code}
      root: "test/code/reform",
      file: "intro_test.rb"
    )


    html = Torture::Cms::Section.({template: template, exec_context: section_cell})
      end
    end
  end
end


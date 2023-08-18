require "test_helper"

class TortureServerTest < Minitest::Spec
  it "what" do
    pages = {
      "cells" => {
        title: "Cells",
        "4.0" => { # "prefix/version"
          snippet_dir: "../cells/test/docs",
          section_dir: "cells/4.0",
          "overview.md.erb" => { snippet_file: "cell_test.rb" }
        },
        "5.0" => {

        }
      },
      "reform" => {
        title: "Reform",
        "2.3" => {
          snippet_dir: "../reform/test/docs",
          section_dir: "reform/2.x",

        }
      }
    }

    require "cell"
    require "cells/__erb__"


    require "torture/cms/section"
    require "torture/cms/helper/header"
    require "torture/cms/helper/code"

    require "torture/snippet"

    module My
      module Cell
        class Section # #Torture::Cms::Section
          include Torture::Cms::Helper::Header # needs {headers}
          include Torture::Cms::Helper::Code   # needs {extract}

          def initialize(options)
            @options = options
          end
        end
      end
    end

    title = "Reform"
    require "torture/toc"
    page_header = Torture::Toc.Header(title, 1, {id: nil}) # FIXME: remove mutability.
    headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.


    # TODO: version "slug"

    template = Cell::Erb::Template.new("test/cms/snippets/reform/intro.md.erb")

    section_cell = My::Cell::Section.new(
      headers: headers,

      # for {code}
      root: "test/code/reform",
      file: "intro_test.rb"
    )


    html = Torture::Cms::Section.({template: template, exec_context: section_cell})

    assert_equal html, %(asdf)
  end
end

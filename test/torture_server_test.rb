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
          snippet_dir: "test/code/reform",
          section_dir: "test/sections/reform",
          "intro.md.erb" => { snippet_file: "intro_test.rb" }
        }
      }
    }

    require "cell"
    require "cells/__erb__"


    require "torture/cms"

    require "kramdown"

    module My
      module Cell
        # This is delibarately a PORO, and not a cell, to play with the "exec_context" concept.
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

# generate section
    template = Cell::Erb::Template.new("test/sections/reform/intro.md.erb")

    section_cell = My::Cell::Section.new(
      headers: headers,

      # for {code}
      root: "test/code/reform",
      file: "intro_test.rb"
    )


    html = Torture::Cms::Section.({template: template, exec_context: section_cell})

# puts html
    assert_equal html, %(<span class="divider"></span>

      <h2 id="reform-introduction">Introduction</h2> <!-- {reform-introduction-toc} -->

Deep stuff.

<span class="divider"></span>

      <h3 id="reform-introduction-deep-profound">Deep & profound</h3> <!-- {reform-introduction-deep-profound-toc} -->

test


<pre><code>99.must_equal 99
</code></pre>




<pre><code>and profound
</code></pre>

)
  end
end

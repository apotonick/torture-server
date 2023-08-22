require "test_helper"

class TortureServerTest < Minitest::Spec
  it "what" do
    FileUtils.rm_rf("test/site")

    pages = {
      "cells" => {
        title: "Cells",
        "4.0" => { # "prefix/version"
          snippet_dir: "test/cells/",
          section_dir: "test/sections/cells/4.0",
          target_file: "test/site/2.1/docs/cells/index.html",
          "overview.md.erb" => { snippet_file: "cell_test.rb" }
        },
        "5.0" => {
          snippet_dir: "test/cells-5/",
          section_dir: "test/sections/cells/5.0",
          target_file: "test/site/2.1/docs/cells/5.0/index.html",
        }
      },
      "reform" => {
        title: "Reform",
        "2.3" => {
          snippet_dir: "test/code/reform",
          section_dir: "test/sections/reform",
          target_file: "test/site/2.1/docs/reform/index.html",
          "intro.md.erb" => { snippet_file: "intro_test.rb" },
          "controller.md.erb" => { snippet_file: "intro_test.rb" }, # uses @options[:controller]
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

          def initialize(headers:, controller:, **options) # DISCUSS: how to define incoming dependencies?
            @options = options.merge(headers: headers, controller: controller)
          end
        end
      end
    end

    pages = pages.collect do |name, options| # TODO: extract me!
      Torture::Cms::Site.new.render_versioned_pages(**options, section_cell: My::Cell::Section, section_cell_options: {controller: Object})
    end
# pp pages

    assert_equal `tree test/site`, %(test/site
└── 2.1
    └── docs
        ├── cells
        │   ├── 5.0
        │   │   └── index.html
        │   └── index.html
        └── reform
            └── index.html

5 directories, 3 files
)

    assert_equal File.open("test/site/2.1/docs/cells/5.0/index.html").read, %()
    assert_equal File.open("test/site/2.1/docs/cells/index.html").read,
%(<h2 id="cells-what-s-a-cell-">What's a cell?</h2>

<p>Paragraph needs an a tag.</p>

<ul>
  <li>And</li>
  <li>a</li>
  <li>comprehensive list.</li>
</ul>
)
    assert_equal File.open("test/site/2.1/docs/reform/index.html").read,
%(<h2 id="reform-introduction">Introduction</h2>

<p>Deep stuff.</p>

<h3 id="reform-introduction-deep-profound">Deep &amp; profound</h3>

<p>test</p>

<pre><code>99.must_equal 99
</code></pre>

<pre><code>and profound
</code></pre>


<p>Object</p>
)

#     assert_equal pages, [[["4.0",
#    ["<h1>Cells</h1>\n",

#     "<span class=\"divider\"></span>\n" +
#     "\n" +
#     "      <h2 id=\"cells-what-s-a-cell-\">What's a cell?</h2> <!-- {cells-what-s-a-cell--toc} -->\n"]],
#   ["5.0", ["<h1>Cells</h1>\n",]]],
#  [["2.3",
#    ["<h1>Reform</h1>\n",

#     "<span class=\"divider\"></span>\n" +
#     "\n" +
#     "      <h2 id=\"reform-introduction\">Introduction</h2> <!-- {reform-introduction-toc} -->\n" +
#     "\n" +
#     "Deep stuff.\n" +
#     "\n" +
#     "<span class=\"divider\"></span>\n" +
#     "\n" +
#     "      <h3 id=\"reform-introduction-deep-profound\">Deep & profound</h3> <!-- {reform-introduction-deep-profound-toc} -->\n" +
#     "\n" +
#     "test\n" +
#     "\n" +
#     "\n" +
#     "<pre><code>99.must_equal 99\n" +
#     "</code></pre>\n" +
#     "\n" +
#     "\n" +
#     "\n" +
#     "\n" +
#     "<pre><code>and profound\n" +
#     "</code></pre>\n" +
#     "\n"]]]]




#     title = "Reform"
#     require "torture/toc"
#     page_header = Torture::Toc.Header(title, 1, {id: nil}) # FIXME: remove mutability.
#     headers     = {1 => [page_header], 2 => [], 3 => [], 4 => [], 5 => []} # mutable state, hmm.


#     # TODO: version "slug"

# # generate section
#     template = Cell::Erb::Template.new("test/sections/reform/intro.md.erb")

#     section_cell = My::Cell::Section.new(
#       headers: headers,

#       # for {code}
#       root: "test/code/reform",
#       file: "intro_test.rb"
#     )


#     html = Torture::Cms::Section.({template: template, exec_context: section_cell})

# # puts html
#     assert_equal html, %(<span class="divider"></span>

#       <h2 id="reform-introduction">Introduction</h2> <!-- {reform-introduction-toc} -->

# Deep stuff.

# <span class="divider"></span>

#       <h3 id="reform-introduction-deep-profound">Deep & profound</h3> <!-- {reform-introduction-deep-profound-toc} -->

# test


# <pre><code>99.must_equal 99
# </code></pre>




# <pre><code>and profound
# </code></pre>

# )
  end
end

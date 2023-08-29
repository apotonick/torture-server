require "test_helper"

class DSLTest < Minitest::Spec
  it "what" do
    pages = {
      "reform" => {
        title: "Reform",
        "2.3" => {
          snippet_dir: "test/code/reform",
          section_dir: "test/sections/reform",
          target_file: "test/site/2.1/docs/reform/index.html",
          layout:      {cell: "layout"}, # DISCUSS: with .md, too?
          "intro.md.erb" => { snippet_file: "intro_test.rb" },
          # "controller.md.erb" => { snippet_file: "intro_test.rb" }, # uses @options[:controller]
        }
      },
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
    }

    books = Torture::Cms::DSL.(pages)
# pp books
    assert_equal books, {
     "reform"=>
      {"2.3"=>
        {:sections=>{"intro.md.erb"=>{:snippet_file=>"intro_test.rb"}},
         :options=>
          {:snippet_dir=>"test/code/reform",
           :section_dir=>"test/sections/reform",
           :target_file=>"test/site/2.1/docs/reform/index.html",
           :layout=>{:cell=>"layout"}}}},
     "cells"=>
      {"4.0"=>
        {:sections=>{"overview.md.erb"=>{:snippet_file=>"cell_test.rb"}},
         :options=>
          {:snippet_dir=>"test/cells/",
           :section_dir=>"test/sections/cells/4.0",
           :target_file=>"test/site/2.1/docs/cells/index.html"}},
       "5.0"=>
        {:sections=>{},
         :options=>
          {:snippet_dir=>"test/cells-5/",
           :section_dir=>"test/sections/cells/5.0",
           :target_file=>"test/site/2.1/docs/cells/5.0/index.html"}}}
    }
  end
end

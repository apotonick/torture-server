require "test_helper"

class TortureServerTest < Minitest::Spec
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

        def to_h
          {headers: @options[:headers]}
        end
      end
    end
  end

  class RenderWithLeftTocAndPageLayout < Trailblazer::Activity::Railway
    # step Torture::Cms::Page.method(:render_page), id: :render_page # TODO: add {render_section}

    # Render left_toc.
    step Torture::Cms::Page.method(:render_cell).clone,
      id: :left_toc,
      In() => ->(ctx, layout:, level_1_headers:, **) { {context_class: layout[:left_toc][:context_class], template: layout[:left_toc][:template], options_for_cell: {headers: level_1_headers}} },
      Out() => {:content => :left_toc_html}

    # Render "page layout" (not the app layout).
    step Torture::Cms::Page.method(:render_cell),
      id: :render_page,
      # In() => {:layout => :cell_options},
      # In() => [:left_toc_html, :content],
      In() => ->(ctx, layout:, left_toc_html:, content:, **options) { {**layout, options_for_cell: {yield_block: content, left_toc_html: left_toc_html, version_options: options}} }
  end

  let(:reform_index) {
    pages = {
      "reform" => {
        title: "Reform",
        "2.3" => {
          snippet_dir: "test/code/reform",
          section_dir: "test/sections/reform",
          target_file: "test/site/2.1/docs/reform/index.html",
          target_url:  "/2.1/reform",
          "intro.md.erb" => { snippet_file: "intro_test.rb" },
          # "controller.md.erb" => { snippet_file: "intro_test.rb" }, # uses @options[:controller]
        }
      }
    }
  }

  it "accepts {pre} and {code} classes" do
    pages = Torture::Cms::DSL.(reform_index)

    pages = Torture::Cms::Site.new.render_pages(pages, section_cell: My::Cell::Section, section_cell_options: {controller: nil,
      pre_attributes: {class: "mt-4"},
      code_attributes: {class: "rounded"},
    })
    assert_equal pages[0].to_h["2.3"][:target_file], "test/site/2.1/docs/reform/index.html"
    content = pages[0].to_h["2.3"][:content]

    #@ <p> has class!
    assert_equal content,
%(<h2 id="reform-introduction" class="">Introduction</h2>

<p>Deep stuff.</p>

<h3 id="reform-introduction-deep-profound" class="">Deep &amp; profound</h3>

<p>test with <code>code span</code>.</p>

<pre class="mt-4"><code class="rounded">assert 99 &gt;= 99 # model=&gt;#&lt;Song name=\"nil\"&gt;
</code></pre>

<pre class="mt-4"><code class="rounded">
and profound</code></pre>
)
  end

  it "accepts {:layout_cell}" do
    layout = Class.new do
      include Torture::Cms::Helper::Toc

      def initialize(left_toc_html:, version_options:)
        @options = {
          left_toc_html: left_toc_html,
          documentation_title: version_options[:title], # the local page version's {:title}
        }
      end

      def to_h
        {}
      end

      def toc_left
        @options[:left_toc_html]
      end

      def documentation_title
        @options[:documentation_title]
      end
    end

    layout_template = Cell::Erb::Template.new("test/cms/layouts/documentation.erb")

    left_toc = Class.new do
      def initialize(headers:)
        @options = {headers: headers}
      end

      def to_h
        {}
      end
    end

    left_toc_template = Cell::Erb::Template.new("test/cms/layouts/left_toc.erb")
    layout_options = {context_class: layout, template: layout_template, left_toc: {context_class: left_toc, template: left_toc_template}} # DISCUSS: with .md, too?

    pages = {
      "reform" => {
        toc_title: "Reform",
        "2.3" => {
          title: "Reform",
          snippet_dir: "test/code/reform",
          section_dir: "test/sections/reform",
          target_file: "test/site/2.1/docs/reform/index.html",
          target_url:  "/2.1/docs/reform",
          layout:      layout_options,
          render: RenderWithLeftTocAndPageLayout,
          "intro.md.erb" => { snippet_file: "intro_test.rb" },
          "api.md.erb" => {
            snippet_file: "api_test.rb",
            snippet_dir: "test/code/reform/api", # local and different {:snippet_dir}.
          },
          "reform.md.erb" => {section_dir: "test/sections/generic", snippet_file: "reform_test.rb", snippet_dir: "test/code/generic"},
          # "controller.md.erb" => { snippet_file: "intro_test.rb" }, # uses @options[:controller]
        }
      },
      "cells" => {
        toc_title: "Cells",
        "4.0" => { # "prefix/version"
          title: "Cells 4",
          snippet_dir: "test/cells/",
          section_dir: "test/sections/cells/4.0",
          target_file: "test/site/2.1/docs/cells/index.html",
          target_url:  "/2.1/docs/cells",
          layout:       layout_options,
          "overview.md.erb" => { snippet_file: "cell_test.rb" },
          render: RenderWithLeftTocAndPageLayout,
        },
        "5.0" => {
          title: "Cells 5",
          snippet_dir: "test/cells-5/",
          section_dir: "test/sections/cells/5.0",
          target_file: "test/site/2.1/docs/cells/5.0/index.html",
          target_url:  "/2.1/docs/cells/5.0",
        }
      },
    }


    books = Torture::Cms::DSL.(pages)

    # pp books
    # raise

    pages = Torture::Cms::Site.new.render_pages(books, section_cell: My::Cell::Section, section_cell_options: {controller: nil})

    assert_equal pages[0].to_h["2.3"][:target_file], "test/site/2.1/docs/reform/index.html"

    reform_content = pages[0].to_h["2.3"][:content]

    #@ <p> has class!
    assert_equal reform_content,
%(Layout.
<h1>Reform documentation</h1>

  <div>
    <b><a href="/2.1/docs/reform">Reform</a></b>
      <a href="">Introduction</a>
      <a href="">API</a>
  </div>

  <div>
    <b><a href="/2.1/docs/cells">Cells</a></b>
  </div>


<h2 id="reform-introduction" class="">Introduction</h2>

<p>Deep stuff.</p>

<h3 id="reform-introduction-deep-profound" class="">Deep &amp; profound</h3>

<p>test with <code>code span</code>.</p>

<pre><code>assert 99 &gt;= 99 # model=&gt;#&lt;Song name=\"nil\"&gt;
</code></pre>

<pre><code>
and profound</code></pre>

<h2 id=\"reform-api\" class=\"\">API</h2>

<p>Too complex in 2.x.</p>

<pre><code>Constant
</code></pre>

<pre><code>Module
</code></pre>

done.
)

    cell_content = pages[1].to_h["4.0"][:content]

    assert_equal cell_content,
%(Layout.
<h1>Cells 4 documentation</h1>

  <div>
    <b><a href="/2.1/docs/reform">Reform</a></b>
  </div>

  <div>
    <b><a href="/2.1/docs/cells">Cells</a></b>
      <a href="">What's a cell?</a>
  </div>


<h2 id="cells-4-what-s-a-cell-" class="">What's a cell?</h2>

<p>Paragraph needs an a tag.</p>

<ul>
  <li>And</li>
  <li>a</li>
  <li>comprehensive list.</li>
</ul>

done.
)
  end

  it "allows using different Kramdown implementation" do
    class Kramdown::Converter::Fuckyoukramdown < Kramdown::Converter::Html
      def convert_p(el, *args)
        el.attr[:class] = "mt-6"
        super
      end

      def convert_codespan(el, *args)
        el.attr[:class] = "purple"
        super
      end
    end

    pages = Torture::Cms::DSL.(reform_index)

    pages = Torture::Cms::Site.new.render_pages(pages, section_cell: My::Cell::Section, section_cell_options: {controller: nil}, kramdown_options: {converter: "to_fuckyoukramdown"})

    assert_equal pages[0].to_h["2.3"][:target_file], "test/site/2.1/docs/reform/index.html"
    content = pages[0].to_h["2.3"][:content]

    #@ <p> has class!
    assert_equal content,
%(<h2 id="reform-introduction" class="">Introduction</h2>

<p class="mt-6">Deep stuff.</p>

<h3 id="reform-introduction-deep-profound" class="">Deep &amp; profound</h3>

<p class="mt-6">test with <code class="purple">code span</code>.</p>

<pre><code>assert 99 &gt;= 99 # model=&gt;#&lt;Song name=\"nil\"&gt;
</code></pre>

<pre><code>
and profound</code></pre>
)
  end

  before do
    FileUtils.rm_rf("test/site")
  end

  it "what" do
    pages = {
      "cells" => {
        title: "Cells",
        "4.0" => { # "prefix/version"
          snippet_dir: "test/cells/",
          section_dir: "test/sections/cells/4.0",
          target_file: "test/site/2.1/docs/cells/index.html",
          target_url:  "/2.1/cells",
          "overview.md.erb" => { snippet_file: "cell_test.rb" }
        },
        "5.0" => {
          snippet_dir: "test/cells-5/",
          section_dir: "test/sections/cells/5.0",
          target_file: "test/site/2.1/docs/cells/5.0/index.html",
          target_url:  "/2.1/cells/5.0",
        }
      },
      "reform" => {
        title: "Reform",
        "2.3" => {
          snippet_dir: "test/code/reform",
          section_dir: "test/sections/reform",
          target_file: "test/site/2.1/docs/reform/index.html",
          target_url:  "/2.1/reform",
          "intro.md.erb" => { snippet_file: "intro_test.rb" },
          "controller.md.erb" => { snippet_file: "intro_test.rb" }, # uses @options[:controller]
        }
      }
    }

    pages = Torture::Cms::DSL.(pages)

    pages = Torture::Cms::Site.new.produce_versioned_pages(pages, section_cell: My::Cell::Section, section_cell_options: {controller: Object})

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
%(<h2 id="cells-what-s-a-cell-" class="">What's a cell?</h2>

<p>Paragraph needs an a tag.</p>

<ul>
  <li>And</li>
  <li>a</li>
  <li>comprehensive list.</li>
</ul>
)
    assert_equal File.open("test/site/2.1/docs/reform/index.html").read,
%(<h2 id="reform-introduction" class="">Introduction</h2>

<p>Deep stuff.</p>

<h3 id="reform-introduction-deep-profound" class="">Deep &amp; profound</h3>

<p>test with <code>code span</code>.</p>

<pre><code>assert 99 &gt;= 99 # model=&gt;#&lt;Song name=\"nil\"&gt;
</code></pre>

<pre><code>
and profound</code></pre>

<p>Object</p>
)
  end
end

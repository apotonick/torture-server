require "test_helper"

require "torture/server"

class TortureTest < Minitest::Spec

# page with snippets and code that gets extracted
  it do
    html, graph = Torture::Server.compile_page(
      page:   "test/cms/pages/activity.md",
      layout: "test/cms/layouts/doc"
    )

# FIXME: p around comments???
# FIXME: p around span???

    html.must_equal %{<html>
  <title>
    Activity  </title>
  <%= table_of_content %>  <h2>Header</h2>
<p>Some text.</p>

<p>and more.</p>

<h1 id=\"title\">Title!</h1>

<p><span class=\"divider\"></span></p>

<h2 id=\"activity-intro\">Intro</h2>
<p><!-- {activity-intro-toc} -->Hello!</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
true.must_equal true
</code></pre>
<p>Great, and then.</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
9.must_equal 9
</code></pre>

<p><span class=\"divider\"></span></p>

<h2 id=\"activity-low-level\">Low Level</h2>
<p><!-- {activity-low-level-toc} -->Deeper.</p>

<p><span class=\"divider\"></span></p>

<h3 id=\"activity-low-level-deep-profound\">Deep &amp; profound</h3>
<p><!-- {activity-low-level-deep-profound-toc} -->test</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
99.must_equal 99
</code></pre>
</html>
}

    graph.inspect.must_equal %{#<struct Torture::Page::HTML::Graph level_to_header={1=>[#<struct Torture::Toc::Header title=\"Activity\", level=1, id=\"activity\", items=[#<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"activity-intro\", items=[]>, #<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"activity-low-level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"activity-low-level-deep-profound\", items=[]>]>]>, #<struct Torture::Toc::Header title=\"Activity\", level=1, id=\"activity\", items=[#<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"activity-intro\", items=[]>, #<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"activity-low-level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"activity-low-level-deep-profound\", items=[]>]>]>], 2=>[#<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"activity-low-level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"activity-low-level-deep-profound\", items=[]>]>, #<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"activity-intro\", items=[]>], 3=>[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"activity-low-level-deep-profound\", items=[]>], 4=>[], 5=>[]}, page_header=#<struct Torture::Toc::Header title=\"Activity\", level=1, id=\"activity\", items=[#<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"activity-intro\", items=[]>, #<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"activity-low-level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"activity-low-level-deep-profound\", items=[]>]>]>>}

    html_with_toc = Torture::Page::Final.new(nil).(:show, table_of_content: "_TOC_", html: html)

    html_with_toc.must_equal %{<html>
  <title>
    Activity  </title>
  _TOC_  <h2>Header</h2>
<p>Some text.</p>

<p>and more.</p>

<h1 id=\"title\">Title!</h1>

<p><span class=\"divider\"></span></p>

<h2 id=\"activity-intro\">Intro</h2>
<p><!-- {activity-intro-toc} -->Hello!</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
true.must_equal true
</code></pre>
<p>Great, and then.</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
9.must_equal 9
</code></pre>

<p><span class=\"divider\"></span></p>

<h2 id=\"activity-low-level\">Low Level</h2>
<p><!-- {activity-low-level-toc} -->Deeper.</p>

<p><span class=\"divider\"></span></p>

<h3 id=\"activity-low-level-deep-profound\">Deep &amp; profound</h3>
<p><!-- {activity-low-level-deep-profound-toc} -->test</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
99.must_equal 99
</code></pre>
</html>
}
  end

# page with snippets and code that gets SUPPRESSED.
  it do
    html, graph = Torture::Server.compile_page(
      page:   "test/cms/pages/activity.md",
      layout: "test/cms/layouts/doc",
      extract: false
    )

    html.must_equal %{<html>
  <title>
    Activity  </title>
  <%= table_of_content %>  <h2>Header</h2>
<p>Some text.</p>

<p>and more.</p>

<h1 id=\"title\">Title!</h1>

<p><span class=\"divider\"></span></p>

<h2 id=\"activity-intro\">Intro</h2>
<p><!-- {activity-intro-toc} -->Hello!</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
</code></pre>
<p>Great, and then.</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
</code></pre>

<p><span class=\"divider\"></span></p>

<h2 id=\"activity-low-level\">Low Level</h2>
<p><!-- {activity-low-level-toc} -->Deeper.</p>

<p><span class=\"divider\"></span></p>

<h3 id=\"activity-low-level-deep-profound\">Deep &amp; profound</h3>
<p><!-- {activity-low-level-deep-profound-toc} -->test</p>

<pre><code class=\"ruby light code-snippet wow fadeIn\">
</code></pre>
</html>
}
  end
end

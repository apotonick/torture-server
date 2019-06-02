require "test_helper"

require "torture/server"

class TortureTest < Minitest::Spec
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

<h2 id=\"Activity-Intro\">Intro</h2>
<p><!-- {Activity-Intro-toc} -->Hello!</p>

<p><span class=\"divider\"></span></p>

<h2 id=\"Activity-Low Level\">Low Level</h2>
<p><!-- {Activity-Low Level-toc} -->Deeper.</p>

<p><span class=\"divider\"></span></p>

<h3 id=\"Activity-Low Level-Deep &amp; profound\">Deep &amp; profound</h3>
<p><!-- {Activity-Low Level-Deep & profound-toc} --></p>
</html>
}

    graph.inspect.must_equal %{#<struct Torture::Page::HTML::Graph level_to_header={1=>[#<struct Torture::Toc::Header title=\"Activity\", level=1, id=\"Activity\", items=[#<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"Activity-Intro\", items=[]>, #<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"Activity-Low Level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"Activity-Low Level-Deep & profound\", items=[]>]>]>, #<struct Torture::Toc::Header title=\"Activity\", level=1, id=\"Activity\", items=[#<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"Activity-Intro\", items=[]>, #<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"Activity-Low Level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"Activity-Low Level-Deep & profound\", items=[]>]>]>], 2=>[#<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"Activity-Low Level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"Activity-Low Level-Deep & profound\", items=[]>]>, #<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"Activity-Intro\", items=[]>], 3=>[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"Activity-Low Level-Deep & profound\", items=[]>], 4=>[], 5=>[]}, page_header=#<struct Torture::Toc::Header title=\"Activity\", level=1, id=\"Activity\", items=[#<struct Torture::Toc::Header title=\"Intro\", level=2, id=\"Activity-Intro\", items=[]>, #<struct Torture::Toc::Header title=\"Low Level\", level=2, id=\"Activity-Low Level\", items=[#<struct Torture::Toc::Header title=\"Deep & profound\", level=3, id=\"Activity-Low Level-Deep & profound\", items=[]>]>]>>}

    html_with_toc = Torture::Page::Final.new(nil).(:show, table_of_content: "_TOC_", html: html)

    html_with_toc.must_equal %{<html>
  <title>
    Activity  </title>
  _TOC_  <h2>Header</h2>
<p>Some text.</p>

<p>and more.</p>

<h1 id=\"title\">Title!</h1>

<p><span class=\"divider\"></span></p>

<h2 id=\"Activity-Intro\">Intro</h2>
<p><!-- {Activity-Intro-toc} -->Hello!</p>

<p><span class=\"divider\"></span></p>

<h2 id=\"Activity-Low Level\">Low Level</h2>
<p><!-- {Activity-Low Level-toc} -->Deeper.</p>

<p><span class=\"divider\"></span></p>

<h3 id=\"Activity-Low Level-Deep &amp; profound\">Deep &amp; profound</h3>
<p><!-- {Activity-Low Level-Deep & profound-toc} --></p>
</html>
}
  end
end

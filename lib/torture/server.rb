require "torture/server/version"
require "cells"
require "cell/erb"
require "kramdown"

module Torture
  module Server
    module_function

    # HTML without TOCs substituted.
    #
    # activity.md.erb
    #   snippets :intro, :debugging
    #
    # => html with toc, toc graph
    def compile_page(page:, layout:, **options)
      Page::HTML.new(nil).(:show, page: page, path: "./", layout: layout, **options)
    end
  end
end

require "torture/page_options"
require "torture/snippets"
require "torture/toc"

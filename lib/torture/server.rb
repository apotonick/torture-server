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
    def compile_page(page:, path:, layout:)
      Page::HTML.new(nil).(:show, page: page, path: path, layout: layout)
    end
  end
end

require "torture/page_options"
require "torture/snippets"
require "torture/toc"

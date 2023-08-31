module Torture
  module Cms

  end
end

require "trailblazer/activity/dsl/linear"

require "torture/cms/dsl"
require "torture/cms/site"
require "torture/cms/page"
require "torture/toc" # FIXME: wrong namespace
require "torture/cms/section"
require "torture/cms/helper/header"
require "torture/cms/helper/code"
require "torture/cms/helper/toc"

require "torture/snippet"

require "torture/cms/kramdown" # FIXME: Tailwind specific

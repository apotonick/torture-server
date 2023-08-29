$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
# require "torture/server"

require "minitest/autorun"

  require "cell"
  require "cells/__erb__"


require "torture/cms"

class Minitest::Spec
  def assert_equal(expected, asserted, *args)
    super(asserted, expected, *args)
  end
end

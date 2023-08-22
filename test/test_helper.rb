$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
# require "torture/server"

require "minitest/autorun"

class Minitest::Spec
  def assert_equal(expected, asserted, *args)
    super(asserted, expected, *args)
  end
end

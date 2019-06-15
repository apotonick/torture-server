require "test_helper"

class BasicsTest < Minitest::Spec
  it "what" do

  end

  it "yo" do
    #:example
    true.must_equal true
    #:example end

    false.must_equal false

    #:more
    9.must_equal 9
    #:more end

  end


end

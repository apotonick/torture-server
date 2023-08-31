require "test_helper"

class ReformTest < Minitest::Spec
  it "what" do

  end

  it "yo" do
    #:example
    "".must_equal ""
    #:example end

    false.must_equal false

    #:deep
    assert 99 >= 99
    #:deep end

  end


end

require "test_helper"

class ReformTest < Minitest::Spec
  it "what" do
    #:overview
    class Form
    end
    #:overview end
  end

  it "yo" do
    #:example
    "".must_equal ""
    #:example end

    false.must_equal false

    # Here, we test proper escaping of HTML entities such as < and >
    #:deep
    assert 99 >= 99 # model=>#<Song name="nil">
    #:deep end

  end
end

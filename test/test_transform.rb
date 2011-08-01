$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'minitest/autorun'
require 'minitest/spec'
require 'thnad/transform'

include Thnad

describe Transform do
  before do
    @transform = Thnad::Transform.new
  end

  it 'transforms a number' do
    input    = {:number => '42'}
    expected = Thnad::Number.new(42)

    @transform.apply(input).must_equal expected
  end
end

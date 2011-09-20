$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
$: << File.expand_path(File.dirname(__FILE__))

require 'minitest/autorun'
require 'minitest/spec'
require 'thnad/nodes'
require 'fake_builder'

include Thnad

describe 'Nodes' do
  before do
    @context = Hash.new
    @builder = FakeBuilder.new
  end

  it 'emits a number' do
    input    = Thnad::Number.new 42
    expected = <<HERE
push 42
HERE
    input.eval @context, @builder

    @builder.result.must_equal expected
  end
end

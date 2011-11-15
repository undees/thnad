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

  it 'emits a function call' do
    @context['foo'] = 667

    input    = Thnad::Funcall.new 'baz', [Thnad::Number.new(42),
                                          Thnad::Name.new('foo')]
    expected = <<HERE
push_self
push 42
push 667
allow_private
send :baz, 2
HERE

    input.eval @context, @builder

    @builder.result.must_equal expected
  end
end

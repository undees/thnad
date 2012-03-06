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
    @context[:params] = 'foo'

    input    = Thnad::Funcall.new 'baz', [Thnad::Number.new(42),
                                          Thnad::Name.new('foo')]
    expected = <<HERE
push_self
push 42
push_local 0
allow_private
send :baz, 2
HERE

    input.eval @context, @builder

    @builder.result.must_equal expected
  end

  it 'emits a conditional' do
    input    = Thnad::Conditional.new \
      Thnad::Number.new(0),
      Thnad::Number.new(42),
      Thnad::Number.new(667)
    expected = <<HERE
push 0
push 0
send :==, 1
goto_if_true label_1
push 42
goto label_2
label_1:
push 667
label_2:
HERE

    input.eval @context, @builder
    @builder.result.must_equal expected
  end

  it 'emits a function definition' do
    input    = Thnad::Function.new \
      'foo',
      Thnad::Name.new('x'),
      Thnad::Number.new(5)

    expected = <<HERE
dynamic_method :foo
push 5
ret
HERE

    input.eval @context, @builder
    @builder.result.must_equal expected
  end
end

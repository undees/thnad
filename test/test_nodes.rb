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
ldc 42
HERE
    input.eval @context, @builder

    @builder.result.must_equal expected
  end

  it 'emits a function call' do
    @context[:params] = ['foo']

    input    = Thnad::Funcall.new 'baz', [Thnad::Number.new(42),
                                          Thnad::Name.new('foo')]
    expected = <<HERE
ldc 42
iload 0
invokestatic example, baz, int, int, int
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
ldc 0
ifeq else
ldc 42
goto endif
label else
ldc 667
label endif
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
public_static_method foo, int, int
ldc 5
ireturn
HERE

    input.eval @context, @builder
    @builder.result.must_equal expected
  end
end

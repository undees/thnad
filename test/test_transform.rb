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

  it 'transforms a name' do
    input    = {:name => 'foo'}
    expected = Thnad::Name.new('foo')

    @transform.apply(input).must_equal expected
  end

  it 'transforms an argument list' do
    input    = {:args => [{:arg => {:number => '42'}},
                          {:arg => {:name   => 'foo'}}]}
    expected = [Thnad::Number.new(42),
                Thnad::Name.new('foo')]

    @transform.apply(input).must_equal expected
  end

  it 'transforms a single-argument function call' do
    input = {:funcall => {:name => 'foo'},
             :args    => [{:arg => {:number => '42'}}]}
    expected = Thnad::Funcall.new 'foo', [Thnad::Number.new(42)]

    @transform.apply(input).must_equal expected
  end

  it 'transforms a multi-argument function call' do
    input = {:funcall => {:name => 'baz'},
             :args    => [{:arg => {:number => '42'}},
                          {:arg => {:name => 'foo'}}]}
    expected = Thnad::Funcall.new 'baz', [Thnad::Number.new(42),
                                          Thnad::Name.new('foo')]

    @transform.apply(input).must_equal expected
  end

  it 'transforms a conditional' do
    input = {:cond     => {:number => '0'},
             :if_true  => {:body => {:number => '42'}},
             :if_false => {:body => {:number => '667'}}}
    expected = Thnad::Conditional.new \
      Thnad::Number.new(0),
      Thnad::Number.new(42),
      Thnad::Number.new(667)

    @transform.apply(input).must_equal expected
  end

  it 'transforms a function definition' do
    input = {:func   => {:name => 'foo'},
             :params => {:param => {:name => 'x'}},
             :body   => {:number => '5'}}
    expected = Thnad::Function.new \
      'foo',
      [Thnad::Name.new('x')],
      Thnad::Number.new(5)

    @transform.apply(input).must_equal expected
  end
end

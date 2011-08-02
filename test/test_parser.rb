$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'minitest/autorun'
require 'minitest/spec'
require 'thnad/parser'

include Thnad

describe Parser do
  before do
    @parser = Thnad::Parser.new
  end

  it 'reads a number' do
    input    = '42 '
    expected = {:number => '42'}

    @parser.number.parse(input).must_equal expected
  end

  it 'reads a name' do
    input    = 'foo '
    expected = {:name => 'foo'}

    @parser.name.parse(input).must_equal expected
  end

  it 'reads an argument list' do
    input    = '(42, foo)'
    expected = {:args => [{:arg => {:number => '42'}},
                          {:arg => {:name   => 'foo'}}]}

    @parser.args.parse(input).must_equal expected
  end

  it 'reads a function call' do
    input = 'baz(42, foo)'
    expected = {:funcall => {:name => 'baz' },
                :args    => [{:arg => {:number => '42'}},
                             {:arg => {:name => 'foo'}}]}

    @parser.funcall.parse(input).must_equal expected
  end

  it 'reads a conditional' do
    input = <<HERE
if (0) {
  42
} else {
  667
}
HERE

    expected = {:cond     => {:number => '0'},
                :if_true  => {:body => {:number => '42'}},
                :if_false => {:body => {:number => '667'}}}

    @parser.cond.parse(input).must_equal expected
  end

  it 'reads a function definition' do
    input    = <<HERE
function foo(x) {
  5
}
HERE
    expected = {:func   => {:name => 'foo'},
                :params => {:param => {:name => 'x'}},
                :body   => {:number => '5'}}
    @parser.func.parse(input).must_equal expected
  end
end

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
end

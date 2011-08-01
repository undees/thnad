class FakeBuilder
  attr_reader :result

  def initialize
    @result = ''
  end

  def method_missing(name, *args, &block)
    @result += "#{name} #{args.join(',')}\n"
  end
end

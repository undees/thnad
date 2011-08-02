class FakeBuilder
  attr_reader :result

  def initialize
    @result = ''
  end

  def class_builder
    return 'example'
  end

  def int
    return 'int'
  end

  def method_missing(name, *args, &block)
    @result += "#{name} #{args.join(', ')}\n"
  end
end

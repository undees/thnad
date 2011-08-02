class FakeBuilder
  attr_reader :result

  def initialize
    @result = ''
  end

  def class_builder
    'example'
  end

  def int
    'int'
  end

  def method_missing(name, *args, &block)
    @result += ([name] + args.flatten).join(', ').sub(',', '')
    @result += "\n"
    block.call(self) if name.to_s == 'public_static_method'
  end
end

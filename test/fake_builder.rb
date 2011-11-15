class FakeBuilder
  attr_reader :result

  def initialize
    @result = ''
  end

  undef_method :send

  def method_missing(name, *args, &block)
    @result += args.empty? ?
      "#{name}\n"          :
      "#{name} #{args.map(&:inspect).join(', ')}\n"
  end
end

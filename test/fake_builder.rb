class FakeLabel
  def initialize(builder, label_id)
    @builder  = builder
    @label_id = label_id
  end

  def set!
    @builder.method_missing(inspect + ':')
  end

  def inspect
    "label_#{@label_id}"
  end
end

class FakeBuilder
  attr_reader :result, :num_labels

  def initialize
    @result = ''
    @num_labels = 0
  end

  def int
    'int'
  end

  def new_label
    @num_labels += 1
    FakeLabel.new self, @num_labels
  end

  undef_method :send

  def method_missing(name, *args, &block)
    @result += args.empty? ?
      "#{name}\n"          :
      "#{name} #{args.map(&:inspect).join(', ')}\n"
    block.call(self) if name.to_s == 'dynamic_method'
  end
end

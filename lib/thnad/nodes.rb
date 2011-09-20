module Thnad
  class Number < Struct.new :value
    def eval(context, builder)
      builder.push value
    end
  end
end

module Thnad
  class Number < Struct.new :value
    def eval(context, builder)
      builder.ldc value
    end
  end
end

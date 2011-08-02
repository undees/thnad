module Thnad
  class Number < Struct.new :value
    def eval(context, builder)
      builder.ldc value
    end
  end

  class Name < Struct.new :name
    def eval(context, builder)
      value = context.fetch(name) { raise "Unknown parameter #{name}" }
      builder.ldc value
    end
  end

  class Funcall < Struct.new :name, :args
    def eval(context, builder)
      args.each { |a| a.eval(context, builder) }
      types = [builder.int] * (args.length + 1)
      builder.invokestatic builder.class_builder, name, types
    end
  end
end

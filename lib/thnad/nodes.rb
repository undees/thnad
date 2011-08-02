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

  class Conditional < Struct.new :cond, :if_true, :if_false
    def eval(context, builder)
      cond.eval context, builder

      builder.ifeq :else

      if_true.eval context, builder
      builder.goto :endif

      builder.label :else
      if_false.eval context, builder

      builder.label :endif
    end
  end
end

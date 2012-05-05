module Thnad
  class Number < Struct.new :value
    def eval(context, builder)
      builder.ldc value
    end
  end

  class Name < Struct.new :name
    def eval(context, builder)
      param_names = context[:params] || []
      position    = param_names.index(name)
      raise "Unknown parameter #{name}" unless position

      builder.iload position
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

  class Function < Struct.new :name, :params, :body
    def eval(context, builder)
      param_names = [params].flatten.map(&:name)
      context[:params] = param_names
      types = [builder.int] * (param_names.count + 1)

      builder.public_static_method(self.name, [], *types) do |method|
        self.body.eval(context, method)
        method.ireturn
      end
    end
  end
end

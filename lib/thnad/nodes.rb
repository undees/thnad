module Thnad
  class Number < Struct.new :value
    def eval(context, builder)
      builder.push value
    end
  end

  class Name < Struct.new :name
    def eval(context, builder)
      param_names = context[:params] || []
      position    = param_names.index(name)
      raise "Unknown parameter #{name}" unless position

      builder.push_local position
    end
  end

  class Funcall < Struct.new :name, :args
    def eval(context, builder)
      builder.push_thnad_receiver
      args.each { |a| a.eval(context, builder) }
      builder.allow_private
      builder.send name.to_sym, args.length
    end
  end

  class Conditional < Struct.new :cond, :if_true, :if_false
    def eval(context, builder)
      else_label  = builder.new_label
      endif_label = builder.new_label

      # if (cond == 0) ...
      cond.eval context, builder
      builder.push 0
      builder.send :==, 1

      # ... then evaluate "else" clause ...
      builder.goto_if_true else_label

      # ... otherwise, fall through to:

      # body of "if" clause
      if_true.eval context, builder
      builder.goto endif_label

      # body of "else" clause
      else_label.set!
      if_false.eval context, builder

      endif_label.set!
    end
  end

  class Function < Struct.new :name, :params, :body
    def eval(context, builder)
      param_names = (params.is_a?(Array) ? params : [params]).map(&:name)
      context[:params] = param_names

      self.body.eval(context, builder)
      builder.ret
    end
  end
end

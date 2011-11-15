module Thnad
  class Number < Struct.new :value
    def eval(context, builder)
      builder.push value
    end
  end

  class Name < Struct.new :name
    def eval(context, builder)
      value = context.fetch(name) { raise "Unknown parameter #{name}" }
      builder.push value
    end
  end

  class Funcall < Struct.new :name, :args
    def eval(context, builder)
      builder.push_self
      args.each { |a| a.eval(context, builder) }
      builder.allow_private
      builder.send name.to_sym, args.length
    end
  end
end

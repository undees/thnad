require 'thnad/parser'
require 'thnad/transform'
require 'thnad/builtins'

class Rubinius::Generator
  def set_thnad_receiver
    push_rubinius
    push_literal :Thnad
    push_const :Object
    send :new, 0
    send :const_set, 2
    pop
  end

  def push_thnad_receiver
    push_const :Thnad
  end
end


module Thnad
  class Compiler
    def initialize(filename)
      @filename  = filename
      @classname = File.basename(@filename, '.thnad').capitalize
      @outname   = File.basename(@filename, '.thnad') + '.rbc'
    end

    def compile
      tree      = parse_source
      funcs, exprs = split_functions tree
      classname = @classname
      klass     = make_class(classname)

      g = Rubinius::Generator.new
      g.name = @classname.to_sym
      g.file = @filename.to_sym
      g.set_line 1
      g.push_rubinius
      g.add_scope
      g.set_thnad_receiver

      g.push_thnad_receiver
      inner = Rubinius::Generator.new
      inner.name = :minus
      inner.file = @filename.to_sym
      inner.set_line 1
      inner.required_args = 2
      inner.total_args = inner.required_args
      inner.push_local 0
      inner.push_local 1
      inner.send :-, 1
      inner.ret
      inner.close
      inner.use_detected
      inner.encode

      cm = inner.package Rubinius::CompiledMethod

      g.push_rubinius
      g.push_literal :minus
      g.push_literal cm
      g.push_scope
      g.push_thnad_receiver
      g.send :attach_method, 4
      g.pop

      g.push_thnad_receiver
      inner = Rubinius::Generator.new
      inner.name = :times
      inner.file = @filename.to_sym
      inner.set_line 1
      inner.required_args = 2
      inner.total_args = inner.required_args
      inner.push_local 0
      inner.push_local 1
      inner.send :*, 1
      inner.ret
      inner.close
      inner.use_detected
      inner.encode

      cm = inner.package Rubinius::CompiledMethod

      g.push_rubinius
      g.push_literal :times
      g.push_literal cm
      g.push_scope
      g.push_thnad_receiver
      g.send :attach_method, 4
      g.pop

      funcs.each do |f|
        inner = Rubinius::Generator.new
        inner.name = f.name.to_sym
        inner.file = @filename.to_sym
        inner.set_line 1
        inner.required_args = f.params.count
        inner.total_args = inner.required_args

        context = Hash.new
        f.eval(context, inner)

        inner.close
        inner.use_detected
        inner.encode

        cm = inner.package Rubinius::CompiledMethod

        g.push_rubinius
        g.push_literal f.name.to_sym
        g.push_literal cm
        g.push_scope
        g.push_thnad_receiver
        g.send :attach_method, 4
        g.pop
      end

      context = Hash.new
      exprs.each do |e|
        e.eval(context, g)
      end

      g.push_true
      g.ret

      g.close
      g.use_detected
      g.encode

      main = g.package Rubinius::CompiledMethod

      Rubinius::CompiledFile.dump main, @outname, Rubinius::Signature, 18
    end

    private

    def parse_source
      source    = File.expand_path(@filename)
      program   = IO.read source

      parser    = Parser.new
      transform = Transform.new
      syntax    = parser.parse(program)
      tree      = transform.apply(syntax)

      tree.is_a?(Array) ? tree : [tree]
    end

    def split_functions(tree)
      first_expr = tree.index { |t| ! t.is_a?(Function) }
      funcs = first_expr ? tree[0...first_expr] : tree
      exprs = first_expr ? tree[first_expr..-1] : []

      [funcs, exprs]
    end

    def make_class(name)
      Object.const_set name.to_sym, Class.new
    end
  end
end

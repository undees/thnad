require 'thnad/parser'
require 'thnad/transform'

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

  def current_method; @inner end

  def begin_method(name, num_args)
    push_thnad_receiver

    inner = Rubinius::Generator.new
    inner.name = name
    inner.file = file
    inner.set_line 1
    inner.required_args = num_args
    inner.total_args = inner.required_args

    @inner = inner
    return inner
  end

  def end_method
    inner = @inner

    inner.close
    inner.use_detected
    inner.encode

    cm = inner.package Rubinius::CompiledMethod

    push_rubinius
    push_literal inner.name
    push_literal cm
    push_scope
    push_thnad_receiver
    send :attach_method, 4
    pop
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

      g.begin_method :minus, 2
      g.current_method.push_local 0
      g.current_method.push_local 1
      g.current_method.send :-, 1
      g.current_method.ret
      g.end_method

      funcs.each do |f|
        context = Hash.new
        f.eval(context, g)
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

      Array(tree)
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

require 'bitescript'
require 'thnad/parser'
require 'thnad/transform'
require 'thnad/builtins'

module Thnad
  class Compiler
    def initialize(filename)
      @filename  = filename
      @classname = File.basename(@filename, '.thnad')
    end

    def compile
      tree         = parse_source
      funcs, exprs = split_functions tree
      classname    = @classname

      builder = BiteScript::FileBuilder.build(@filename) do
        public_class classname, object do |klass|
          klass.extend(Builtins)
          klass.add_builtins

          funcs.each do |f|
            context = Hash.new
            f.eval(context, klass)
          end

          klass.public_static_method 'main', [], void, string[] do |method|
            context = Hash.new
            exprs.each do |e|
              e.eval(context, method)
            end

            method.returnvoid
          end
        end
      end

      write_result builder
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

    def write_result(builder)
      destination = File.expand_path(@classname + '.class')

      builder.generate do |n, b|
        File.open(destination, 'wb') do |f|
          f.write b.generate
        end
      end
    end
  end
end

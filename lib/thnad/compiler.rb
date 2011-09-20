require 'thnad/parser'
require 'thnad/transform'
require 'thnad/builtins'

module Thnad
  class Compiler
    def initialize(filename)
      @filename  = filename
      @classname = File.basename(@filename, '.thnad').capitalize
    end

    def compile
      tree      = parse_source
      classname = @classname
      klass     = make_class(classname)

      klass.dynamic_method :main do |generator|
        context = Hash.new
        tree.each do |e|
          e.eval(context, generator)
        end

        generator.ret
      end

      puts klass.new.main
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

    def write_result(builder)
      destination = File.expand_path(@classname + '.class')

      builder.generate do |n, b|
        File.open(destination, 'wb') do |f|
          f.write b.generate
        end
      end
    end

    def make_class(name)
      Object.const_set name.to_sym, Class.new
    end
  end
end

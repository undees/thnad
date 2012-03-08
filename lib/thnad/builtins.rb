require 'java'
java_import java.lang.System
java_import java.io.PrintStream

module Thnad
  module Builtins
    def add_builtins
      public_static_method 'print', [], int, int do
        iload 0

        getstatic System, :out, PrintStream
        swap
        invokevirtual PrintStream, :print, [void, int]

        ldc 0
        ireturn
      end

      public_static_method 'minus', [], int, int, int do
        iload 0
        iload 1
        isub
        ireturn
      end
    end
  end
end

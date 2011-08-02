module Thnad
  module Builtins
    def add_builtins
      public_static_method 'print', [], int, int do
        iload 0
        println(int)
        ldc 0
        ireturn
      end
    end
  end
end

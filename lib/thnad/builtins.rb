module Thnad
  module Builtins
    def add_builtins
      public_static_method 'print', [], int, int do
        iload 0
        println(int)
        ldc 0
        ireturn
      end

      public_static_method 'eq', [], int, int, int do
        iload 0
        iload 1
        if_icmpeq :eq
        ldc 0
        goto :endeq
        label :eq
        ldc 1
        label :endeq
        ireturn
      end

      public_static_method 'times', [], int, int, int do
        iload 0
        iload 1
        imul
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

# Thnad

_A fictional programming language_

Thnad is a tiny programming language with so few features that it is not useful for anything at all--except showing how to write a compiler in half an hour.

Here's the factorial function in Thnad:

    function factorial(n) {
      if(eq(n, 1)) {
        1
      } else {
        times(n, factorial(minus(n, 1)))
      }
    }
    
    print(factorial(4))

The language has only the following dubious features:

* Integer literals
* Functions
* Conditionals (with a required "else")

That's it! Math and comparison are function calls. IO (or rather just O, as there is no input) is a simple print function.

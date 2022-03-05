# -*- mode:org;mode:auto-fill;fill-column:79 -*-
#+title: MaxPC Extensions 
#+author: Nicholas Hubbard

Extensions for Max Rottenkolber's [[rovides][MaxPC parser library]].

* Functionality

*** =identity (value)

Return VALUE without consuming any input.

*** %bind (parser make-parser)

Monadic bind function.

*** %let* (bindings &body body)

Convience macro around chaning together =%bind= calls. Allows binding the
output of intermediate parsers to variables that can be used as input to
subsequent parsers. Variables named _ are ignored.

Example:
#+BEGIN_SRC 
(%let* ((foo (=foo-parser))
        (bar (=bar-parser))
        (_   (?blah-parser))
        (baz (=baz-parser foo bar))
  (list foo bar baz)))
#+END_SRC 
*** ?null ()

Succeed and return NIL without consuming any input.

*** =eq (x &optional (parser (=element)))

Same as ?EQ but return the matching input as a string.

*** =not (parser)

Same as ?NOT but return the matching subsequence.

*** =satisfies (test &optional (parser (=element)))

Same as ?SATISFIES but returns the matching subsequence.

*** =string (string)

Match the string STRING and return it.

*** =one-of (&rest strings)

Match one of the strings in STRINGS and return it.

*** =any (parser)

Same as ?ANY but return the matching subsequence.

*** =some (parser)

Same as %SOME but return the matching subsequence

*** %prog1 (&rest parsers)

Match PARSERS in sequence and return the result of the first parser.

*** %progn (&rest parsers)

Match PARSERS in sequence and return the result of the last parser.

*** =as-keyword (parser)

Transform the string result of PARSER into a keyword symbol.

* Contributing

Feel free to submit a PR for any functionality you deem fit.

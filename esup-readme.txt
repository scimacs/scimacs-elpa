The most recent code is always at http://github.com/jschaf/esup

esup profiles your Emacs startup time by examining all top-level
S-expressions (sexps).  esup starts a new Emacs process from Emacs
to profile each SEXP.  After the profiled Emacs is complete, it
will exit and your Emacs will display the results.


We need `esup-result'
(require 'esup-child)


On Emacs 24.3 and below, the `with-slots' macro expands to `symbol-macrolet'
instead of `cl-symbol-macrolet'
(eval-when-compile
  (if (and (<= emacs-major-version 24)
           (<= emacs-minor-version 3))
      (require 'cl)
    (require 'cl-lib)))

;;;; Extensions for Max Rottenkolber's MaxPC parsing library.

(defpackage #:maxpc-ext
  (:documentation "Extensions for Max Rottenkolber's MaxPC parsing library.")
  (:use #:cl #:maxpc #:maxpc.char)
  (:export #:parse-success-p
           #:parse-total-success-p
           #:%bind
           #:=identity
           #:%let*
           #:?null
           #:=eq
           #:=not
           #:=satisfies
           #:=string
           #:=one-of
           #:=any
           #:=some
           #:%prog1
           #:%progn
           #:=as-keyword))

;;; ----------------------------------------------------

(defun parse-success-p (input parser)
  "Return T if applying PARSER to INPUT results in a successful parse and NIL
otherwise."
  (handler-case
      (nth-value 1 (parse input parser))
    (error (e) (declare (ignore e)) nil)))

;;; ----------------------------------------------------

(defun parse-total-success-p (input parser)
  "Return t if applying PARSER to INPUT results in a successful parse, and 
consumes all of INPUT and return NIL otherwise."
  (handler-case
      (multiple-value-bind (_ matched end-of-input) (parse input parser)
        (declare (ignore _))
        (and matched end-of-input))
    (error (e) (declare (ignore e)) nil)))

;;; ----------------------------------------------------

(defun %bind (parser make-parser)
  "Monadic bind function."
  (lambda (input)
    (multiple-value-bind (rest value) (funcall parser input)
      (when rest
        (funcall (funcall make-parser value) rest)))))

;;; ----------------------------------------------------

(defun =identity (val)
  "Always succeeds and returns VAL without consuming any input."
  (lambda (input) (values input val)))

;;; ----------------------------------------------------

(defmacro %let* (bindings &body body)
  "Convenience macro around chaining together %BIND calls with a culminating.
This macro allows defining parsers in a style much like Haskell's do notation.

Example: (%let* ((foo (=foo-parser))
                 (bar (=bar-parser))
                 (_   (?blah-parser))
                 (baz (=baz-parser foo bar))
           (list foo bar baz)))"
  (if (null bindings)
      `(=identity (progn ,@body))
      (let* ((binding (first bindings))
             (var     (first binding))
             (parser  (second binding)))
        `(%bind ,parser
                (lambda (,var)
                  ,(when (string= var "_")
                     `(declare (ignore ,var)))
                  (%let* ,(rest bindings) ,@body))))))

;;; ----------------------------------------------------

(defun ?null ()
  "Succeed and return NIL without consuming any input."
  (=identity nil))

;;; ----------------------------------------------------

(defun =eq (x &optional (parser (=element)))
  "Like ?EQ but return the matching input."
  (=subseq (?eq x parser)))

;;; ----------------------------------------------------

(defun =not (parser)
  "Like ?NOT but return the matching input."
  (=subseq (?not parser)))

;;; ----------------------------------------------------

(defun =satisfies (test &optional (parser (=element)))
  "Like ?SATISFIES but return the matching input."
  (=subseq (?satisfies test parser)))

;;; ----------------------------------------------------

(defun =string (string)
  "Attempt to match the characters in STRING in sequence. If successful return
STRING."
  (=subseq (?string string)))

;;; ----------------------------------------------------

(defmacro =one-of (&rest strings)
  "Attempt to parse any string in STRINGS and return the first string in STRINGS
that matches."
  `(%or ,@(loop :for s :in strings
                :collect `(=string ,s))))

;;; ----------------------------------------------------

(defun =any (parser)
  "Like %ANY but return the matching input."
  (=subseq (%any parser)))

;;; ----------------------------------------------------

(defun =some (parser)
  "Like %SOME but return the matching input."
  (=subseq (%some parser)))

;;; ----------------------------------------------------

(defun %prog1 (&rest parsers)
  "Apply PARSERS in sequence and return the output of the first parser."
  (=transform (apply #'=list parsers) #'first))

;;; ----------------------------------------------------

(defun %progn (&rest parsers)
  "Apply PARSERS in sequence and return the output of the last parser."
  (=transform (apply #'=list parsers) (lambda (list) (car (last list)))))

;;; ----------------------------------------------------

(defun =as-keyword (parser)
  "Transform the string result of PARSER into a keyword."
  (=transform parser
              (lambda (string) (intern (string-upcase string) :keyword))))

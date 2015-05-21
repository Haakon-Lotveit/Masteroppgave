;; Loads the program so far. Pretty fragile method of doing things, should be replaced by more robust package management.
;; Running is done by specified files per OS.

(defun fload (file)
  (load (merge-pathnames file *default-pathname-defaults*)))

(let ((*standard-output* (make-broadcast-stream)))
  (fload "aux/auxilliary-functions.lisp")
  (fload "Compiler.lisp")
  (fload "markdown-compiler/list-status.lisp")
  (fload "markdown-compiler/markdown.lisp")
  (fload "front-end-compiler/tokenizer.lisp")
  (fload "front-end-compiler/parser.lisp")
  (fload "front-end-compiler/unit-test-functions.lisp")
  (fload "front-end-compiler/unit-tests.lisp")
  (fload "backend/pdflatex/compile.lisp")
  (fload "glue/running-stuff.lisp"))


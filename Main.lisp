;; Loads and runs the program so far. Pretty fragile method of doing things, should be replaced by more robust package management.
(defun fload (file)
  (load (merge-pathnames file *default-pathname-defaults*)))

(fload "aux/auxilliary-functions.lisp")
(fload "markdown-compiler/list-status.lisp")
(fload "markdown-compiler/markdown.lisp")
(fload "front-end-compiler/tokenizer.lisp")
(fload "front-end-compiler/parser.lisp")
(fload "front-end-compiler/unit-test-functions.lisp")
(fload "front-end-compiler/unit-tests.lisp")
;(fload "front-end-compiler/compiler.lisp")

(defun main (args)
  (write-line args))

(defun start ()
  ;; Start is the entry-point of the program it accepts command-line arguments, and package them into a format that lisp likes.
  ;; Then it sends them off to main.
  ;; It is not advised to call this function from the REPL. `MAIN' is preferred instead."
  (let ((args (make-growable-string)))
    (loop for line = (read-line *standard-input* nil :eof) 
       until (eq line :eof) do 
	 (with-output-to-string (output-stream args)
	   (format output-stream "~A" line)))
    (main args))
  (exit :code 0))


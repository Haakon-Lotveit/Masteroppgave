;; Loads and runs the program so far. Pretty fragile method of doing things, should be replaced by more robust package management.
(load (merge-pathnames "aux/auxilliary-functions.lisp" *default-pathname-defaults*))
(load (merge-pathnames "front-end-compiler/tokenizer.lisp" *default-pathname-defaults*))
(load (merge-pathnames "front-end-compiler/parser.lisp" *default-pathname-defaults*))
(load (merge-pathnames "front-end-compiler/unit-test-functions.lisp" *default-pathname-defaults*))
(load (merge-pathnames "front-end-compiler/unit-tests.lisp" *default-pathname-defaults*))
;(load (merge-pathnames "front-end-compiler/compiler.lisp" *default-pathname-defaults*))

(defun main (args)
  (write-line args))

(defun start ()
  (format nil 
	  "~{~A~^~%~}" 
	  '("Start is the entry-point of the program it accepts command-line arguments, and package them into a format that lisp likes."
	    "Then it sends them off to main."
	    "It is not advised to call this function from the REPL. START is preferred instead."))
  (let ((args (make-growable-string)))
    (loop for line = (read-line *standard-input* nil :eof) 
       until (eq line :eof) do 
	 (with-output-to-string (output-stream args)
	   (format output-stream "~A" line)))
    (main args))
  (exit :code 0))


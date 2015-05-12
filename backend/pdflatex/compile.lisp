;; A horrible hack to load auxilliary functions, because I haven't made a proper ASDF system out of them.
;; This is very likely to break horribly.
(load "../../aux/auxilliary-functions.lisp")

;; This assures SBCL that the function named latex-recursively-handle-text will be defined somewhere in this file, silencing a warning.
(declaim (ftype function latex-recursively-handle-text))

(defun split-on-first-space (list)
  "Splits a list into two lists, at the first occurrence of #\Space. (#\a#\b#\c#\ #\d#\e#\f) → ((#\a#\b#\c) (#\d#\e#\f))"
  (cond 
    ;; Base case, empty string
    ((null list)
     '(nil nil))
    ;; If we find a space, other terminating case
    ((char= #\Space (car list))
     (list nil (cdr list)))
    ;; Recursive case
    ('DEFAULT
     (let* ((rec-res (split-on-first-space (cdr list)))
	    (first (cons (car list) (first rec-res)))
	    (second (second rec-res)))
       (list first second)))))

(defun file-to-list (filename)
  (flet ((append-with-newline (list1 list2)
	   (append list1 '(#\Newline) list2)))
  (reduce #'append-with-newline ;; <3 Høyere ordens programmering <3
	  (with-open-file (stream filename)
	    (loop for line = (read-line stream nil) ;; We read the file per line, in case we want to do line counting or similar.
	       while line
	       collect (coerce line 'list))))))

(defvar *MARKDOWN-TEST-FILE-AS-LIST*
  (file-to-list "../testdata/large-markdown-teststring.mfo")
  "The output of the markdown-compiler's large testing string")

(defvar *PREAMBLE* "% NO PREAMBLE SET %"
  "This variable holds any lines that should go into the document before the compiled stuff.")

(defvar *POSTAMBLE* "% NO POSTAMBLE SET %"
  "This variable holds any lines that should go into the document after the compiled data.")

(defvar *OUTPUT-FILE* (merge-pathnames *DEFAULT-PATHNAME-DEFAULTS* "output-file.pdf")
  "The path to the file we are supposed to output to. This will be what we have when pdf-latex is ready.")

(defvar *INPUT-FILE* nil
  "The path to the file that have been precompiled.")

(defun read-std-input ()
    (let ((args (make-growable-string)))
      (loop for line = (read-line *standard-input* nil :eof) 
	 until (eq line :eof) do 
	   (with-output-to-string (output-stream args)
	     (format output-stream "~A" line)))
      args))

(defun external-entry-point ()
  (format *STANDARD-OUTPUT* "~%I found this at the command line: ~A~%" (read-std-input))
  (exit :code 0))

(defun handle-unknown-command (command text output-stream)
  (format output-stream "~%    %    ERROR!~%    %    Unknown Command: ~A~%    %    Text left as is~%" (coerce command 'string))
  (latex-recursively-handle-text text output-stream))

(defun latex-make-handling-function (open-incantation close-incantation)
  (lambda (charlist stream)
    (format stream "~A" open-incantation)
    (let ((rest (latex-recursively-handle-text charlist stream)))
      (format stream "~A" close-incantation)
      rest)))
(defun begin (command)
  (format nil "~%\\begin{~A}~%" command))

(defun end (command)
  (format nil "~%\\end{~A}~%" command))

(defvar *handling-functions*
  (make-hash-table-from-list
   (list
    (list "CURSIVE" (latex-make-handling-function "\\textit{" "}"))
    (list "UNDERLINE" (latex-make-handling-function "\\uline{" "}"))
    (list "EMPHASISED" (latex-make-handling-function "\\emph{" "}"))
    (list "QUOTE" (latex-make-handling-function (begin "quote") (end "quote")))
    ))
  "This is a lookup of all the functions that are used to handle commands.")

(defun latex-handle-command (charlist stream)
  "Handles a command in the source-code"
  (let* ((split (split-on-first-space charlist))
	 (command-name (coerce (first split) 'string))
	 (textlist (second split)))
    (if (nth-value 1 (gethash command-name *handling-functions*))
	(funcall (gethash command-name *handling-functions*) textlist stream)
	(handle-unknown-command command-name textlist stream))))

(defun latex-recursively-handle-text (text-as-list output-stream)
   (cond
    ;; Base case: Nothing more to process'
    ((null text-as-list)
     nil)

    ;; Case for escape sequence
    ((char= #\\ (car text-as-list))
     (progn
       (write-char (second text-as-list))
       (latex-recursively-handle-text (cddr text-as-list) output-stream)))

    ;; Case for command sequence
    ((char= #\( (car text-as-list))
     (latex-recursively-handle-text
	     (latex-handle-command (cdr text-as-list) output-stream)
	     output-stream))

    ;; Closing a command
    ((char= #\) (car text-as-list))
       (cdr text-as-list))

    ;; The default case for the system: Just output the character
    ('DEFAULT
     (progn
       (write-char (car text-as-list) output-stream)
       (latex-recursively-handle-text (cdr text-as-list) output-stream)))))
 
(defun compile-mfo-file (&key ((:preamble pre) *PREAMBLE*) ((:path filepath)) ((:postamble post) *POSTAMBLE*) ((:stream output) *STANDARD-OUTPUT*))
  (format *STANDARD-OUTPUT* "Compiling file ~A with the preamble ~A and the postamble ~A.~%" filepath pre post)
  (format output "% PREAMBLE START %~%~A~%% PREAMBLE END %~%~%" pre)
  (latex-recursively-handle-text (file-to-list filepath) output)
  (format output "% POSTAMBLE START %~%~A~%% POSTAMBLE END %" post))


(compile-mfo-file :path "../testdata/large-markdown-teststring.mfo")
		  
#| Commands that have been implemented (with unit tests)
 | - Unknown commands
 | - CURSIVE
 | - UNDELINE
 | - EMPHASISE
 | - QUOTE
 |#
  
#| TODO-LIST for commands that are unimplemented:
 | - CITE
 | - NEW-PARAGRAPH
 | - CODE
 | - HORIZONTAL-LINE
 | - HEADLINE (with levels)
 | - URL (with name, link and alt-text)
 | - UNORDERED-LIST
 | - ORDERED-LIST
 | - LINE-ITEM
 | 
 | As well as the commands for the other frontend-producers (namely the other text modes, image and table)
 | Table looks to be rather painful as LaTeX isn't that fond of tables it seems... :D
 | These must all be done by Thursday, I guess?
 |#


#| Stuff that needs to go into preamble:

 \usepackage[normalem]{ulem} – For underlines

 |#

#| Stuff that needs to go into postamble:
 |#

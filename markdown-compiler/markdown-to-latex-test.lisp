;; This is an attempt to write LaTeX out of the strings returned by the markdown parser.
(defvar *working-with* (compile-markdown-string *test-string-small*))

(defvar *latex-compiler--supported-tokens*
  (list "emphasised"))

(defun latex-escape (string)
  string)

(defun emphasised (string)
  (format nil "\\emph{~A}" (latex-escape string)))
 
(defun compile-string (string stream)
  (let ((previous-character #\A)
	(current-character #\A)
	(in-command 0)
	(output-accumulator '())
	(string-accumulator (make-growable-string)))
    (loop for char across string do
	 (setf current-character char)
	 (cond
	   ;; When we hit a command do the following:
	   ;; Check if we're opening a new command. ( not preceeded by \.)
	   ;;   - If so, treat the string accumulator as normal text and put it in the output-accumulator
	   ;;     Then put the 
	   ((and (not (char= previous-character #\\))
		(char= current-character #\())
	    (
	   ;; When we end a command
	   ;; Otherwise
	   ('DEFAULT
	    (vector-push-extend char string-accumulator)))
	 (setf previous-character current-character))
    (push string-accumulator output-accumulator)
    (print output-accumulator)
    (format nil "~{~A~^~}" output-accumulator)))


#| 
    HVORDAN HÅNDTERE ESCAPING?
    1: Begynn med å tenke at vi ikke skal escape.
    2: Hvis vi ikke skal escape, så:
       a: hvis vi ser en #\\ og vi ikke skal escape, så skal vi escape neste iterasjon.
       b: ellers går vi som normalt.
    3: Hvis vi skal escape, så:
       a: putt char i string-accumulatoren uansett.
       b: vi skal ikke escape neste iterasjon
#|

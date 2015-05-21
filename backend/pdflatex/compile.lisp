#|
| Compiler for mfo to latex, meant to be compiled with the pdflatex compiler.
| The compiler assumes that it runs on an AMD64 Ubuntu 14.10 system with the following packages:
| 
| sbcl (ver 2:1.2.3-1ubuntu1)
| texlive (ver 2014.20140717-01ubuntu1)
| 
|#

;; This assures SBCL that the function named latex-recursively-handle-text will be defined somewhere in this file, silencing a warning.
(declaim (ftype function latex-recursively-handle-text))

(defun is-whitespace-or-linep (char)
  (or 
   (char= #\Space char)
   (char= #\Tab char)
   (char= #\Newline char)))

(defun trim-textlist (textlist)
  (if (is-whitespace-or-linep (car textlist))
      (trim-textlist (cdr textlist))
      textlist))

(defun latex-extract-command (list)
  "Splits a list into two lists, at the first occurrence of #\Space, #\Newline, or #\). (#\a#\b#\c#\ #\d#\e#\f) → ((#\a#\b#\c) (#\d#\e#\f))"
  (cond 
    ;; Base case, empty string
    ((null list)
     '(nil nil))
    ;; If we find a space, a tab or a newline; a second terminating case. (nonbreaking spaces will not break.)
    ((or (char= #\Space (car list))
	 (char= #\Tab (car list))
	 (char= #\Newline (car list)))
     (list nil (cdr list)))
    ;; If we have an empty command such as (NEW-PARAGRAPH), a third terminating case.
    ((char= #\) (car list))
     (list nil list))
    ;; Recursive case
    ('DEFAULT
     (let* ((rec-res (latex-extract-command (cdr list)))
	    (first (cons (car list) (first rec-res)))
	    (second (second rec-res)))
       (list first second)))))

(defun collect-string (textlist)
  "Will collect characters from a list of characters until an unescaped #\" appears. Returns a list of two elements, where the first element is the collected string (as a list of characters), and the second is the remainder of the list. Throws an error if the string is not terminated."
  (cond
    ;; Checks for errors in input
    ((null textlist)
     (error "Malformed expression when collecting string."))

    ;; Handles escape-cases
    ((char= #\\ (car textlist))
     (let ((rec-val (collect-string (cddr textlist))))
       (list (cons (cadr textlist) (car rec-val))
	     (cadr rec-val))))

    ;; Handles the terminating #\" character
    ((char= #\" (car textlist))
     (list nil (cdr textlist)))

    ;; Basic recursive case
    ('ELSE
     (let ((rec-val (collect-string (cdr textlist))))
       (list (cons (car textlist) (car rec-val))
	     (cadr rec-val))))))

(defun collect-tag (textlist)
  (cond
    ((is-whitespace-or-linep (car textlist))
     (list () (cdr textlist)))
    ('ELSE
     (let ((rec-val (collect-tag (cdr textlist))))
       (list (cons (car textlist) (first rec-val))
	     (second rec-val))))))

(defun is-open-string-p (textlist)
  (if (char= #\" (car textlist))
      (cdr textlist)
      nil))

(defun parse-tag-val-pair (textlist hash-table)
  (let* ((parse-tag (collect-tag (trim-textlist textlist)))
	 (parse-string (collect-string (is-open-string-p (trim-textlist (second parse-tag))))))
    (setf (gethash (coerce (car parse-tag) 'string) hash-table)
	  (coerce (car parse-string) 'string))
    (cadr parse-string)))

(defun parse-all-tag-val-pairs (textlist hash-table)
  (let ((text (trim-textlist textlist)))
    (cond
      ((char= #\) (car text))
       (cdr text))

      ((char= #\: (car text))
       (parse-all-tag-val-pairs (parse-tag-val-pair text hash-table) hash-table)))))

(defun latex-print-url (textlist stream log-stream)
  (let* ((tags (make-hash-table :test 'equal))
	 (rest (parse-all-tag-val-pairs textlist tags)))
    (unless (nth-value 1 (gethash ":URL" tags))
      (error "No url supplied to command \"URL\" in script."))
    (if (nth-value 1 (gethash ":ALT-NAME" tags))
	(format log-stream "~%%LATEX-PRINT-URL: TAG |:ALT-NAME| ~A ignored for pdflatex.%~%" (gethash ":ALT-NAME" tags)))
    (if (nth-value 1 (gethash ":NAME" tags))
	(format stream "\\href{~A}{~A}" (gethash ":URL" tags) (gethash ":NAME" tags))
	(format stream "\\url{~A}" (gethash ":URL" tags)))
    rest))

(defun file-to-list (filename)
  (flet ((append-with-newline (list1 list2)
	   (append list1 '(#\Newline) list2)))
    (reduce #'append-with-newline ;; <3 Høyere ordens programmering <3
	    (with-open-file (stream filename)
	      
	      (loop for line = (read-line stream nil) ;; We read the file per line, in case we want to do line counting or similar.
		 while line
		 collect (coerce line 'list))))))

(defvar *MARKDOWN-TEST-FILE-AS-LIST*
  (file-to-list "/home/hkl/git/Masteroppgave/backend/testdata/large-markdown-teststring.mfo")
  "The output of the markdown-compiler's large testing string")

(defvar *LOG-STREAM* (make-broadcast-stream))

(defvar *PREAMBLE* (slurp-file "backend/pdflatex/preamble.txt")
  "This variable holds any lines that should go into the document before the compiled stuff.")

(defvar *POSTAMBLE* (slurp-file "backend/pdflatex/postamble.txt")
  "This variable holds any lines that should go into the document after the compiled data.")

(defvar *LATEX-BEGINNING-OF-TABLE-ROW* T)
(defvar *LATEX-TABLE-HEADER* T)

(defun handle-unknown-command (command text output-stream)
  (format output-stream "~%    %    ERROR!~%    %    Unknown Command: ~A~%    %    Text left as is~%" (coerce command 'string))
  (latex-recursively-handle-text text output-stream))

(defun latex-make-handling-function (open-incantation close-incantation)
  (lambda (charlist stream)
    (format stream "~A" open-incantation)
    (let ((rest (latex-recursively-handle-text charlist stream)))
      (format stream "~A" close-incantation)
      rest)))

(defun separate-line (command)
  (format nil "~%~A~%" command))

(defun begin (command)
  (format nil "~%\\begin{~A}~%" command))

(defun end (command)
  (format nil "~%\\end{~A}~%" command))

(defun latex-print-headline (textlist stream log-stream headline-level)
  (cond
    ((= 1 headline-level)
     (funcall (latex-make-handling-function "\\section{" "}") textlist stream))
    ((= 2 headline-level)
     (funcall (latex-make-handling-function "\\subsection{" "}") textlist stream))
    ((= 3 headline-level)
     (funcall (latex-make-handling-function "\\subsubsection{" "}") textlist stream))
    ((= 4 headline-level)
     (funcall (latex-make-handling-function "\\paragraph{" "}") textlist stream))
    ((= 5 headline-level)
     (funcall (latex-make-handling-function "\\subparagraph{" "}") textlist stream))
    ('ELSE
     (progn
       (format log-stream "~%%LATEX-PRINT-HEADLINE Maximum supported headline-level is 5 (which is a subparagraph). Requested level is ~A. Will revert to 5.%~%" headline-level)
       (funcall (latex-make-handling-function "\\subparagraph{" "}")) textlist stream))))


(defun latex-handle-headlines (textlist stream)
  (let* ((hash-table (make-hash-table :test 'equal))
	 (rest-text (parse-tag-val-pair (trim-textlist textlist) hash-table)))
    (latex-print-headline (trim-textlist rest-text) stream *LOG-STREAM* (parse-integer (gethash ":LEVEL" hash-table)))))

(defun latex-handle-image (textlist stream)
  (let* ((hash-table (make-hash-table :test 'equal))
	 (rest-text (parse-tag-val-pair (trim-textlist textlist) hash-table)))
    
    (format stream "\\includegraphics{~A}~%" (gethash ":FILE" hash-table))
    (latex-recursively-handle-text (trim-textlist rest-text) stream)))

(defun latex-handle-table-data (textlist stream)
  (if *LATEX-BEGINNING-OF-TABLE-ROW*
      (write-char #\Space stream)
      (write-char #\& stream))
  (setf *LATEX-BEGINNING-OF-TABLE-ROW* 'NIL)
  (write-char #\Space)
  (latex-recursively-handle-text textlist stream))

(defun latex-handle-row (textlist stream)
  (setf *LATEX-BEGINNING-OF-TABLE-ROW* T)
  (let ((rest-text (latex-recursively-handle-text textlist stream)))
    (format stream " \\\\ \\hline")
    rest-text))


(defun latex-handle-tables (textlist stream)
  (let* ((hash-table (make-hash-table :test 'equal))
	 (rest-text (parse-tag-val-pair (parse-tag-val-pair textlist hash-table) hash-table)))
    (format stream "~%\\begin{tabular}{|")
    (dotimes (i (parse-integer (gethash ":SIZE" hash-table)))
      (format stream "c|"))
    (format stream "}~%\\hline")
    (let ((final-rest-text (latex-recursively-handle-text rest-text stream)))
      (format stream "~%\\end{tabular}~%")
      final-rest-text)))

#|
 ; Size = 3, header = yes		;
\begin{tabular}{|c|c|c|} ← DETTE !
X & X & X \\ \hline ← DISSE VIRKER
X & X & X \\ \hline
X & X & X \\ \hline
\end{tabular} ← OG DETTE! Må er det som må gjøres, så er du FERDIG med back-end! :D
|#
(defvar *handling-functions*
  (make-hash-table-from-list
   (list
    (list "TABLE" #'latex-handle-tables)
    (list "ROW" #'latex-handle-row)
    ;; In LaTeX there are no differences syntactical differences between headers and normal table-data. (unlike say, HTML)
    (list "DATA" #'latex-handle-table-data)
    (list "HEADER" #'latex-handle-table-data) 
    (list "IMAGE" #'latex-handle-image)
    (list "CURSIVE" (latex-make-handling-function "\\textit{" "}"))
    (list "UNDERLINE" (latex-make-handling-function "\\uline{" "}"))
    (list "EMPHASISED" (latex-make-handling-function "\\emph{" "}"))
    (list "QUOTE" (latex-make-handling-function (begin "quote") (end "quote")))
    (list "FOOTNOTE" (latex-make-handling-function "\\footnote{" "}"))
    (list "NEW-PARAGRAPH" (latex-make-handling-function (format nil "~%~%") ""))
    (list "HORIZONTAL-LINE" (latex-make-handling-function (separate-line "\\horizontalline") ""))
    (list "CITE" (latex-make-handling-function "\\cite{" "}"))
    (list "CODE" (latex-make-handling-function (begin "lstlisting") (end "lstlisting")))
    (list "UNORDERED-LIST" (latex-make-handling-function (begin "itemize") (end "itemize")))
    (list "ORDERED-LIST" (latex-make-handling-function (begin "enumerate") (end "enumerate")))
    (list "LINE-ITEM" (latex-make-handling-function "\\item " ""))
    (list "HEADLINE" #'latex-handle-headlines)
    (list "URL" (lambda (charlist stream)
		  (latex-print-url charlist stream *LOG-STREAM*)))
    
    ))
  "This is a lookup of all the functions that are used to handlecommands.")

(defun latex-handle-command (charlist stream)
  "Handles a command in the source-code"
  (let* ((split (latex-extract-command charlist))
	 (command-name (string-upcase (coerce (first split) 'string)))
	 (textlist (second split)))
    (if (nth-value 1 (gethash command-name *handling-functions*))
	(funcall (gethash command-name *handling-functions*) textlist stream)
	(handle-unknown-command command-name textlist stream))))

(defun latex-write-char (char output-stream)
    ;; If we hit normally escapable symbols, we escape them by prepending them with backslashes.
  (cond
    ((or
      (char= char #\&)
      (char= char #\%)
      (char= char #\$)
      (char= char #\#)
      (char= char #\_)
      (char= char #\{)
      (char= char #\}))
     (progn 
       (write-char #\\ output-stream)
       (write-char char output-stream)))

    ;; Tildes must be escaped using a particular sequence  
    ((char= char #\~)
     (format output-stream "\\textasciitilde "))

    ;; Cirumflexes must be escaped using a particular seqence too.
    ((char= char #\^)
     (format output-stream "\\textasciicircum "))
        
    ;; As must backslashes. \\ means to force a newline after all.
    ((char= char #\\)
     (format output-stream "\\textbackslash "))

    ('NORMAL-CHAR-THANK-YOU-JESUS
     (write-char char output-stream))))

(defun latex-recursively-handle-text (text-as-list output-stream)
  (cond
    ;; Base case: Nothing more to process'
    ((null text-as-list)
     nil)

    ;; Case for escape sequence
    ((char= #\\ (car text-as-list))
     (progn
       (latex-write-char (cadr text-as-list) output-stream)
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
       (latex-write-char (car text-as-list) output-stream)
       (latex-recursively-handle-text (cdr text-as-list) output-stream)))))

(defclass pdflatex-compiler (compiler)
  ((name :initform "pdflatex-compiler")
   (version :initform 0.1)))

(defmethod backend-compile ((compiler pdflatex-compiler) infile outfile)
  (with-open-file (outstream outfile :direction :output :if-exists :overwrite :if-does-not-exist :create)
    (format outstream *PREAMBLE*)
    (latex-recursively-handle-text (file-to-list infile) outstream)
    (format outstream *POSTAMBLE*)
    'FINISHED))


(defmethod print-object ((object pdflatex-compiler) stream)
  (format stream "#<~A ver: ~A>"
	  (get-name object)
	  (get-version object)))


(provide-compiler (make-instance 'pdflatex-compiler))


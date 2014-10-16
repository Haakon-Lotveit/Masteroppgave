;; Dette er en begrenset utgave av Markdown-språket med følgende begrensinger: 
;; 
;; - Den tar ikke hensyn til HTML-spans, etc. HTML blir sendt rett igjennom.
;; - Den tar ikke å escaper HTML-tegn, slik som &.
;; - Den fungerer per linje, med hacks for å fikse entiteter som går over flere linjer, slik som blokksitater.
;; - Siden Markdown ikke er en faktisk standard med EBNF-standard grammatikk, kan jeg ta feil på flere viktige områder.
;; 
;; Tekst blir skrevet ut i følgende format:
;; (tekst :format "Markdown 0.1" [STRENG])
;; der [STRENG] er en Common Lisp-streng som kan leses via read. Whitespace kan legges til etter ønske og behov. Newlines i strengen kan, men trenger ikke å escapes.
;; 
;; Ting som er implementert:
;; - kursiv, fet og understreket skrift
;; 
;; Ting som skal implementeres:
;; - Overskrifter
;; - horisontale linjer
;; - paragrafer
;; - lenker
;; - sitater
;; - blokksitater
;; - akademiske henvisninger. (@HENVISNING-NAVN@?)
;; - fotnoter. (§FOTNOTE§?)
;; - ESCAPING \*happy\* skal ikke tolkes som (BOLDED happy).
;; - Håndtering av parenteser. (hva om jeg vil skrive (BOLDED noe) uten at det blir uthevet?)
;; - mm!
;; 
;; Merk at ting ikke er ferdig før det har i alle fall en enhetstest!

					; Her er dependencies
(ql:quickload :cl-ppcre)
(ql:quickload :split-sequence)
(load "../front-end-compiler/auxiliary-functions.lisp") ; Vi vil ha make-hash-table-from-list funksjonen.

(import 'CL-PPCRE:SCAN)
(import 'CL-PPCRE:REGEX-REPLACE)
					; Testdata
(defvar *test-string-large*
"This is not a normal test string.
in fact, it has both /cursive/ words,
some  _underlined_ words, and last but not least,
it has *bolded* words.
Furthermore it has quotes:
> The problem with online citations is that it's hard to know if they are authentic or not.
> - Abraham Lincoln
And block quotes too:

    I see starts, etc.
    Blind Singing Man i good at singing.
    And this concludes the quote.

------------------------------------

And that was a line!

Not to be outdone, here's a list:
  - This is the first item of the list.
  - This is the second item of the list, which makes you less likely to remember the contents.
  - Along with this third item. You tend to remember the beginning and ends of strings the best, you see.
  - This fourth item is the one you're most likely to remember.

And that's about all for now. I should add in some extras, such as:
  1. citations
  2. ordered lists
  3. headers, of the ---- and ==== varieties
  4. headers of the ### H3 ### and ## H2 ## variety.
  5. citations (an extension to the markdown language. I'm thinking about using ¤ (currency char) or § (pragraph char) for citations.")

(defparameter *current-subtest* "Here is some _underlined_ words. This _is_ _important_!")
(defparameter *markdown-indentation-level* 0)
(defparameter *markdown-indentation-step* 4)

(defun increase-markdown-indentation ()
  (incf *markdown-indentation-level* *markdown-indentation-step*))
(defun decrease-markdown-indentation ()
  (decf *markdown-indentation-level* *markdown-indentation-step*))
(defun reset-markdown-indentation-level ()
  (setf *markdown-indentation-level* 0))

(defun split-string-by-newlines (string)
  (SPLIT-SEQUENCE:SPLIT-SEQUENCE #\Newline string))

(defparameter *lister*
  " Her kommer det lister:
  * Dette er en liste uten orden.
  * Her kommer det et element til.
  * Listen er over når det kommer en tom linje.
  * En tom linje er en linje med bare whitespace.

  * Dette er en ny liste.
    - Du kan blande listetegn om du vil.
    - Men dette er en kjedet liste, eller en liste i en liste.
  - Men lister defineres per indentering.

Nå er listene ferdig begge to.")

(defun prettyprint (stream object)
  (dotimes (i *markdown-indentation-level*)
    (format stream " "))

  (format stream "~A" object))

;; Hjelpeklasse
(defclass list-status ()
  ((in-list
    :accessor in-list
    :initform nil
    :initarg :in-list)
   (indentation-spaces
    :accessor indentation-spaces
    :initform '(0)
    :initarg :indentation-spaces)))

(defgeneric increase-indentation (status number))
(defmethod increase-indentation ((status list-status) number)
  (setf (indentation-spaces status)
	(+ (indentation-spaces status) number))
  status)

(defgeneric push-list-indent-level (status new-level))
(defmethod push-list-indent-level ((status list-status) new-level)
  (setf (indentation-spaces status)
	(cons new-level (indentation-spaces status)))
  status)

(defgeneric pop-list-indent-level (status))
(defmethod pop-list-indent-level ((status list-status))
  (pop (indentation-spaces status)))

(defun open-new-unordered-list (status line stream)
  (prettyprint-line stream "(UNORDERED-LIST")
  (update-indentation-spaces status line)
  (setf (in-list status) T)
  (increase-markdown-indentation))
  
(defun close-list (status stream)
    (format stream ")")
    (pop-list-indent-level status)
    (when (= (first (indentation-spaces status)) 0)
      (setf (in-list status) nil))
    (decrease-markdown-indentation))

(defgeneric currently-indented-spaces (status))
(defmethod currently-indented-spaces ((status list-status))
  (first (indentation-spaces status)))

(defmethod print-object ((status list-status) stream)
  (format stream "#<status-list in-list: ~A indentation-spaces: ~>" (in-list status) (indentation-spaces status)))


(defun prettyprint-line (stream object)
  (format stream "~%")

  (prettyprint stream object))

(defun remove-list-stuff (string)
  (regex-replace "\\A\\s*(\\*|-)\\s*" string ""))

(defun count-spaces (string)
  (second (multiple-value-list (scan " *" (CL-PPCRE:regex-replace-all "\\t" string "    ")))))

(defun add-line-item (line stream)
  (let ((line-item (format 'nil "(LINE-ITEM ~A)" (prin1-to-string (remove-list-stuff line)))))
    (prettyprint-line stream line-item)))

(defun update-indentation-spaces (status line)
  (push-list-indent-level status (count-spaces line)))

(defun deal-with-list (list-status output-stream line)
  (if (in-list list-status)
      (cond
	((> (count-spaces line) (currently-indented-spaces list-status))
	 (open-new-unordered-list list-status line output-stream))
	((< (count-spaces line) (currently-indented-spaces list-status))
	 (close-list list-status output-stream)))
      (progn
	(open-new-unordered-list list-status line output-stream)))
  (add-line-item line output-stream))

(defun deal-with-no-list (list-status output-stream line)
  "Lukker listen, setter status til å ikke være i en liste, og senker indenteringsnivået ett hakk."
  (when (in-list list-status)
    (close-list list-status output-stream))
  (prettyprint-line output-stream line))


(defun interpret-unordered-lists (input-string)
  (reset-markdown-indentation-level)
  (let ((output-string (make-growable-string))
	(status (make-instance 'list-status))
	(current-line 1))
    (with-output-to-string (stream output-string)
      ;; Explanation of regex:
      ;; Start of string, or post-newline, some-or none whitespace, a * or a -,
      ;; and then some-or-none whitespace
      (let* ((find-unordered-lists-regexp "(^|\\n)\\s*(\\*|-)\\s*") 
	     (lines (split-string-by-newlines input-string)))
	(loop for line in lines do
	       (if (scan find-lists-regexp line)
		   (deal-with-list status stream line)
		   (deal-with-no-list status stream line))
	     (incf current-line))))
    output-string))

;; This is bullshit, and should be refactored to a more user-friendly expression of love.
;; Better idea would be to have functions for everything that could be done, and then just chain those funcalls together.
;; But this stuff is staying for now, until I have something better, just so I have something to look at.
(defun compile-string (string output-stream)
  (format output-stream "~%(text :markdown-standard~%")

  (let ((current-line 1)
	(output-string (make-growable-string)))
    (with-output-to-string (stream output-string)
      (loop for line in (SPLIT-SEQUENCE:SPLIT-SEQUENCE #\Newline string) do
	   (compile-line line stream current-line)
	   (format stream "~%")
	   (incf current-line)))
    (format output-stream (prin1-to-string output-string)))

  (format output-stream ")"))

;;TODO: Refactor this to be a part of compile-string.
(defun compile-line (line output-stream line-number)
  (let* ((output-string (make-growable-string))
	 ;;TODO: Refactor this into something better.
	 
	 (special-tokens (make-hash-table-from-list
			  '((#\* "BOLD")
			    (#\_ "UNDERLINE")
			    (#\/ "CURSIVE"))))
	 (special-states (make-hash-table-from-list
			  '(("BOLD" nil)
			    ("UNDERLINE" nil)
			    ("CURSIVE" nil))))
	 (syntactic-functions (make-hash-table-from-list
			       (list (list 
				      "BOLD" (lambda (state stream)
					       (if state
						   (format stream ")")
						   (format stream "(BOLD "))
					       (setf (gethash "BOLD" special-states) (not state))))
				     (list
				      "UNDERLINE" (lambda (state stream)
						    (if state
							(format stream ")")
							(format stream "(UNDERLINE "))
						    (setf (gethash "UNDERLINE" special-states) (not state))))
				     (list
				      "CURSIVE" (lambda (state stream)
						  (if state
						      (format stream ")")
						      (format stream "(CURSIVE "))
						  (setf (gethash "CURSIVE" special-states) (not state))))))))
    (with-output-to-string (stream output-string)
      ;; Check for special rules, such as whole-lines etc, that terminates parsing of the line.
      (cond
      ;; If a line is composed of only zero or more characters of whitespace, 
      ;; then at least four dashes (-), and then zero or more characters of whitespace,
      ;; then the entire line should be interpreted as: "(vertical-space)".
	((let ((match (cl-ppcre:scan "\\s*----+\\s*" line)))
	   (and (not (null match))
		(= 0 match)))
	 (format stream "(~A)~%" "HORIZONTAL-LINE"))
	('otherwise
	 ;; If no terminating special rules have been found, check the generic rules.
	 (loop for char across line do
	      (let ((lookup (gethash char special-tokens)))
		(if lookup
		    (let ((state (gethash lookup special-states)))
		      (funcall (gethash lookup syntactic-functions) state stream))
		    (format stream "~A" char)))))))

    ;;After we've printed everything to the string, let's print the string where it's supposed to go:
    (format output-stream output-string)
    ;;Finally, check that there are no open tags.
    (maphash (lambda (key val)
	       (unless (null val)
		 (error "On line number ~D:~%\"~A\"~%The directive \"~A\" was opened, but not closed afterwards.~%"			
			line-number
			line
			key)))
	     special-states)))
	       
(compile-string *current-subtest* *standard-output*)
(compile-string *test-string-large* *standard-output*)

	

	

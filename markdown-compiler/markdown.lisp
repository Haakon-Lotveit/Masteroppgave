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

(defun compile-string (string output-stream)
  (format output-stream "~%(text :markdown-standard~%")

  (let ((output-string (make-growable-string)))
    (with-output-to-string (stream output-string)
      (loop for line in (SPLIT-SEQUENCE:SPLIT-SEQUENCE #\N string) do
	   (compile-line line stream)))
    (format output-stream (prin1-to-string output-string)))

  (format output-stream ")"))

(defun compile-line (line output-stream)
  (let* ((output-string (make-growable-string))
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
      (loop for char across line do
	   (let ((lookup (gethash char special-tokens)))
	     (if lookup
		 (let ((state (gethash lookup special-states)))
		   (funcall (gethash lookup syntactic-functions) state stream))
		 (format stream "~A" char)))))

    ;;After we've printed everything to the string, let's print the string where it's supposed to go:
    (format output-stream output-string)))
	       

(compile-string *current-subtest* *standard-output*)
(compile-string *test-string-large* *standard-output*)


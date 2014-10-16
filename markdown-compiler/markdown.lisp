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
;; - lister
;; - akademiske henvisninger. (§sitering§?)
;; - fotnoter. (¤fotnote¤)
;; - horisontale linjer
;; 
;; Ting som skal implementeres:
;; - Overskrifter
;; - paragrafer
;; - lenker
;; - sitater
;; - blokksitater
;; - ESCAPING \*happy\* skal ikke tolkes som (BOLDED happy).
;; - Håndtering av parenteser. (hva om jeg vil skrive (BOLDED noe) uten at det blir uthevet?)
;; - mm!
;; 
;; Merk at ting ikke er ferdig før det har i alle fall en enhetstest! Kan legges inn i *test-string-large*

					; Her er dependencies
(ql:quickload :cl-ppcre)
(ql:quickload :split-sequence)
(load "../front-end-compiler/auxiliary-functions.lisp") ; Vi vil ha make-hash-table-from-list funksjonen.

(import 'CL-PPCRE:SCAN)
(import 'CL-PPCRE:REGEX-REPLACE)
					; Testdata
(defparameter *test-string-large*
"This is not a normal test string.
in fact, it has both /cursive/ words,
some  _underlined_ words, and last but not least,
it has *bolded* words.
Furthermore it has quotes:
> The problem with online citations is that it's hard to know if they are authentic or not.
> - Abraham Lincoln §Lincoln1984§
And block quotes too:

    I see starts, etc.
    Blind Singing Man¤Stevie Wonder selvsagt¤ is very good at singing.
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
  5. citations (an extension to the markdown language.")

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

(defparameter *lister* "Lister kjem:

  * dette er en liste uten orden.
  * andre elementet av Listen
  * listen er over når det kommer noe som ikke er en del av en liste.
  * En tom linje er en linje med bare whitespace.

  * Dette er en ny liste.
    1 Du kan blande listetegn om du vil.
    1 Dette er en liste i en liste.
  * Men lister defineres per indentering.

  1. Akkurat nå kan du ikke kjede lister i hverandre
  2. Det er fordi lukkingen av lister har en bug i seg.
  4  Men tallene foran listene har ingenting å si.

Der var listene ferdig.
")

(defun prettyprint (stream object)
  (dotimes (i *markdown-indentation-level*)
    (format stream " "))

  (format stream "~A" object))

(defun prettyprint-line (stream object)
  (format stream "~%")

  (prettyprint stream object))

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

(defun count-spaces (string)
  (second (multiple-value-list (scan " *" (CL-PPCRE:regex-replace-all "\\t" string "    ")))))

(defun update-indentation-spaces (status line)
  (push-list-indent-level status (count-spaces line)))

(defun open-new-unordered-list (status line stream)
  (prettyprint-line stream "(UNORDERED-LIST")
  (update-indentation-spaces status line)
  (setf (in-list status) T)
  (increase-markdown-indentation))

(defun open-new-ordered-list (status line stream)
  (prettyprint-line stream "(ORDERED-LIST")
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
  (format stream "#<status-list in-list: ~A indentation-spaces: ~A>" (in-list status) (indentation-spaces status)))


(defun remove-list-stuff (string)
  (regex-replace "\\A\\s*(\\*|-|\\d)\\.?\\s*" string ""))

(defun add-line-item (line stream)
  (let ((line-item (format 'nil "(LINE-ITEM ~A)" (remove-list-stuff line))))
    (prettyprint-line stream line-item)))

(defun deal-with-ordered-list (list-status output-stream line)
  (if (in-list list-status)
      (cond
	((> (count-spaces line) (currently-indented-spaces list-status))
	 (open-new-ordered-list list-status line output-stream))
	((< (count-spaces line) (currently-indented-spaces list-status))
	 (close-list list-status output-stream)))
      (progn
	(open-new-ordered-list list-status line output-stream)))
  (add-line-item line output-stream))

(defun deal-with-unordered-list (list-status output-stream line)
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

(defun interpret-lists (input-string)
  (reset-markdown-indentation-level) ;; dette burde ikke behøves, men er der akkurat nå likevel
  (let ((output-string (make-growable-string))
	(status (make-instance 'list-status))
	(current-line 1))
(with-output-to-string (stream output-string)
      (let* ((find-ordered-lists-regexp "\\A\\s*\\d+\\s*")
	     (find-unordered-lists-regexp "\\A\\s*(\\*|-)\\s*") 
	     (lines (split-string-by-newlines input-string)))
	(loop for line in lines do
	     (cond ((scan find-ordered-lists-regexp line)
		    (deal-with-ordered-list status stream line))
		   ((scan find-unordered-lists-regexp line)
		    (deal-with-unordered-list status stream line))
		   ('NO-LISTS-FOUND
		    (deal-with-no-list status stream line)))
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

(defun open-tag (name stream)
  (format stream "(~A " name))

(defun close-tag (stream)
  (format stream ")"))

;; Must be run after the list-checkers.
(defun interpret-toggle-chars (input-string relevant-char tag-name)
  (let ((output-string (make-growable-string))
	(currently-toggled nil))
    (with-output-to-string (stream output-string)
      (loop for char across input-string do
	   (if (char= char relevant-char)
	       (if currently-toggled
		   (progn (close-tag stream)
			  (setf currently-toggled nil))
		   (progn (open-tag tag-name stream)
			  (setf currently-toggled T)))
	       (format stream "~A" char))))
    output-string))

(defun interpret-horizontal-line-rules (input-string)
  (let ((output-string (make-growable-string))
	;; entire line is: some-or-none whitespace, at least four dashes (-) and then some or none whitespace
	(match-lines-regex "\\A\\s*-{4,}\\s*\\Z") )
    (with-output-to-string (stream output-string)
      (loop for line in (split-string-by-newlines input-string) do
	   (if (scan match-lines-regex line)
	       (progn (open-tag "HORIZONTAL-LINE" stream)
		      (close-tag stream))
	       (prettyprint-line stream line))))
    output-string))
	       
;; This runs all the current rules.
;; Currently headers (either type), quotes and block-quotes have not been implemented.
(defun run-all-the-rules! ()
  (reset-markdown-indentation-level)
  (interpret-toggle
   (interpret-toggle 
    (interpret-toggle 
     (interpret-toggle 
      (interpret-toggle 
       (interpret-lists 
       (interpret-horizontal-line-rules *test-string-large*)) #\/ "CURSIVE") #\* "BOLD") #\_ "UNDERLINE") #\§ "CITE") #\¤ "FOOTNOTE"))


	

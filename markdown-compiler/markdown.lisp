;; Dette er en begrenset utgave av Markdown-språket med følgende begrensinger: 
;; 
;; - Den tar ikke hensyn til HTML-spans, etc. HTML blir sendt rett igjennom.
;; - Den tar ikke å escaper HTML-tegn, slik som &.
;; - Den fungerer per linje, med hacks for å fikse entiteter som går over flere linjer, slik som blokksitater.
;; - Siden Markdown ikke er en faktisk standard med EBNF-standard grammatikk, kan jeg ta feil på flere viktige områder.
;; - Ikke at jeg ønsker å implementere "Markdown" helt korrekt heller, siden deler av språket er merkelige greier.
;; 
;; Ting som er implementert:
;; - kursiv, fet og understreket skrift
;; - lister
;; - akademiske henvisninger. (§sitering§?)
;; - fotnoter. (¤fotnote¤)
;; - sitater
;; - horisontale linjer, selv om de nå er feil. De skal være noe ala: ([-+*]\\s+){3,} som helt sikkert er feil. 
;; - ESCAPING \*happy\* skal ikke tolkes som (TAG happy), men som *happy*
;; - Håndtering av parenteser. () blir nå til \(\) i output.
;; 
;; Ting som skal implementeres:
;; - Overskrifter (De er det som nå blir tolket som horisontale linjer. H2 i alle fall.)
;; - paragrafer (Sjekk om vi har to whitespace linjer på rad, og hvis vi så har...)
;; - lenker (Kven veit heilt korleis?)
;; - indentering av et dokument
;; - trimming av dokumentet (unødvendig mye plass tatt opp både foran og bak)
;; - mm!
;; 
;; Merk at ting ikke er ferdig før det har i alle fall en enhetstest! Kan legges inn i *test-string-large*

					; Her er dependencies
(ql:quickload :cl-ppcre)
(ql:quickload :split-sequence)
(load "../front-end-compiler/auxiliary-functions.lisp") ; Vi vil ha make-hash-table-from-list funksjonen.

(import 'CL-PPCRE:SCAN)
(import 'CL-PPCRE:REGEX-REPLACE)
(import 'CL-PPCRE:REGEX-REPLACE-ALL)
					; Testdata
(defparameter *test-string-large*
"This is not a normal test string.
in fact, it has both /cursive/ words,
some  _underlined_ words, and last but not least,
it has *bolded* words.
Furthermore it has quotes:
> The problem with online citations is that it's hard to know if they are authentic or not.
> - Abraham Lincoln §Lincoln1984§
And monospaced text too:

    public class HelloWorld¤The classic Java Hello World example¤ {
        public static void main(String[] args) {
            System.out.println(\"Hello World!\");
        }
    }

------------------------------------

And that was a line!
Please note that the current in-between language treats parens as magical characters unless escaped.
So if you want to use parens (like this!), you have to escape them with forward-slashes (\\)

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
  5. citations (an extension to the markdown language.)")

					; globs that can be easily changed
(defparameter *markdown-indentation-level* 0)
(defparameter *markdown-indentation-step* 4)
(defparameter *tabs-are-this-many-spaces* 4)

(defun increase-markdown-indentation ()
  (incf *markdown-indentation-level* *markdown-indentation-step*))
(defun decrease-markdown-indentation ()
  (decf *markdown-indentation-level* *markdown-indentation-step*))
(defun reset-markdown-indentation-level ()
  (setf *markdown-indentation-level* 0))

(defun split-string-by-newlines (string)
  (SPLIT-SEQUENCE:SPLIT-SEQUENCE #\Newline string))

(defun prettyprint (stream object)
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
	
(defun open-tag (name stream)
  (format stream "(~A " name))

(defun close-tag (stream)
  (format stream ")"))

(defun remove-quote-stuff (line)
  (regex-replace "\\A\\s*>\\s+" line " "))

(defun interpret-quotes (input-string)
  (let ((output-string (make-growable-string))
	(match-quote-regex "\\A\\s*>\\s+")
	(inside-quotes nil)
	(lines (split-string-by-newlines input-string)))
    (with-output-to-string (stream output-string)
      (loop for line in lines do
	   (cond
	     ((scan match-quote-regex line)
	      (when (not inside-quotes)
		(prettyprint-line stream "")
		(open-tag "QUOTE" stream)
		(setf inside-quotes T))
	      (prettyprint-line stream (remove-quote-stuff line)))
	     ('WHEN-WE-DO-NOT-HAVE-A-QUOTE
	      (when inside-quotes
		(setf inside-quotes NIL)
		(close-tag stream))
	      (prettyprint-line stream line)))))
    output-string))

(defun interpret-toggle-regex (input-string regex-rule tag-name)
  (let ((output-string (copy-seq input-string))
	(toggle-flag nil))
    (loop while (scan regex-rule output-string) do
	 (setf output-string
	       (regex-replace regex-rule output-string
			      (if toggle-flag
				  ")"
				  (format nil "(~A " tag-name))))
	 (setf toggle-flag (not toggle-flag)))
    output-string))
	     
(defun is-whitespace-linep (line)
  (if (scan "\\A\\s*\\Z" line)
      T
      NIL))

(defun interpret-horizontal-line-rules (input-string)
  (let ((output-string (make-growable-string))
	;; entire line is: some-or-none whitespace, at least four dashes (-) and then some or none whitespace
	;; TODO: This is actually wrong. That's Markdown's code for an H2 header. :D
	(match-lines-regex "\\A\\s*-{4,}\\s*\\Z")
	(previous-line-was-whitespaced T))
    (with-output-to-string (stream output-string)
      (loop for line in (split-string-by-newlines input-string) do
	   (if (scan match-lines-regex line)
	       (if previous-line-was-whitespaced
		   (progn (prettyprint-line stream "")
			  (open-tag "HORIZONTAL-LINE" stream)
			  (close-tag stream))
		   (format 't "Skal ikke linjes, fordi forrige linje var ikke whitespace"))
	       (prettyprint-line stream line))
	       (setf previous-line-was-whitespaced (is-whitespace-linep line))))
    output-string))

(defun escape-parens (input-string)
  (regex-replace-all "\\)"
		     (regex-replace-all "\\(" input-string "\\(")
		     "\\)"))

(defun remove-n-chars-from-string (n string)
  (subseq string n))

(defun tab-replacement ()
  (coerce (make-array *tabs-are-this-many-spaces* :initial-element #\Space) 'string))

(defun count-spaces (string)
  (let ((spaces 0))
    (loop for character across (regex-replace-all "\\t" string (tab-replacement)) while (char= character #\Space) do (incf spaces))
    spaces))

(defun interpret-code-literal-rules (input-string)
  "NOTE: This *must* be run *after* the list interpretations have been run."
  (let ((output-string (make-growable-string))
	(currently-in-code-block nil)
	(match-code-block-regex "\\A( {4,}|\\s*\\t\\s*)"))
    (with-output-to-string (stream output-string)
    (loop for line in (split-string-by-newlines input-string) do
	 (let ((this-line-is-code-block (scan match-code-block-regex line)))
	   (cond
	     (this-line-is-code-block
	      (unless currently-in-code-block
		(setf currently-in-code-block (count-spaces line))
		(prettyprint-line stream "")
		(open-tag "CODE" stream))
	      (format stream "~%~A" (remove-n-chars-from-string currently-in-code-block line)))
	     ((not this-line-is-code-block) 
	      (when currently-in-code-block
		(setf currently-in-code-block nil)
		(close-tag stream))
	      (prettyprint-line stream line))))))
	     output-string))

;; These are functions that deal with the management of all these rules.
;; The previous stuff is either special case rules (lines and lists for example), or general case rules generation.
;; (Although lists could do with some simplification.)
(defparameter *rules*
  (make-hash-table :test 'equal))

(defun set-rule (rule-name rule)
  (setf (gethash rule-name *rules*) rule))

(defun make-toggle-regex-rule (regex tag-name)
  (lambda (input-string)
    (interpret-toggle-regex input-string regex tag-name)))

(defun make-and-set-toggle-regex-rule (rule-name tag-name regex)
  (set-rule rule-name (make-toggle-regex-rule regex tag-name)))

(defun apply-rule (rule-name string)
  (let ((rule (gethash rule-name *rules*)))
    (unless rule
      (error "No rule called \"~A\" found." rule-name))
    (funcall rule string)))

					; This sets up some standard rules to be used later.
(make-and-set-toggle-regex-rule "EMPHASISED" "EMPHASISED" "(?<!\\\\)\\*")
(make-and-set-toggle-regex-rule "BOLD" "BOLD" "(?<!\\\\)__")
(make-and-set-toggle-regex-rule "CITE" "CITE" "(?<!\\\\)§")
(make-and-set-toggle-regex-rule "FOOTNOTE" "FOOTNOTE" "(?<!\\\\)¤")
(make-and-set-toggle-regex-rule "UNDERLINE" "UNDERLINE" "(?<!\\\\)_")
(make-and-set-toggle-regex-rule "CURSIVE" "CURSIVE" "(?<!\\\\)\\/")
(set-rule "ESCAPE-PARENS" #'escape-parens)
(set-rule "HORIZONTAL-LINE" #'interpret-horizontal-line-rules)
(set-rule "LISTS" #'interpret-lists)
(set-rule "CODE-BLOCKS" #'interpret-code-literal-rules)
(set-rule "QUOTES" #'interpret-quotes)

;; An ad-hoc unit-test, that runs all the rules, who have been added manually.
(defun run-all-the-rules! ()
  (let ((output (copy-seq *test-string-large*)))
    ;; We could just chain these calls, but it looks nicer when we setf them.
    ;; Notice that HORIZONTAL-LINE must run before LISTS
    ;; Interestingly, it should be okay if we run them in alphabetical order. ^_^
    (setf output (apply-rule "ESCAPE-PARENS" output))
    (setf output (apply-rule "HORIZONTAL-LINE" output))
    (setf output (apply-rule "LISTS" output))
    (setf output (apply-rule "CODE-BLOCKS" output))
    (setf output (apply-rule "QUOTES" output))
    (setf output (apply-rule "CURSIVE" output))
    (setf output (apply-rule "UNDERLINE" output))
    (setf output (apply-rule "FOOTNOTE" output))
    (setf output (apply-rule "CITE" output))
    (setf output (apply-rule "BOLD" output))
    (setf output (apply-rule "EMPHASISED" output))
    output))

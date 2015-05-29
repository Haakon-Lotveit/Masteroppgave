;; Dette er en begrenset utgave av Markdown-språket med følgende begrensinger: 
;; 
;; - Den tar ikke hensyn til HTML-spans, etc. HTML blir sendt rett igjennom.
;; - Den tar ikke å escaper HTML-tegn, slik som &.
;; - Den fungerer per linje, med hacks for å fikse entiteter som går over flere linjer, slik som blokksitater.
;; - Siden Markdown ikke er en faktisk standard med EBNF-standard grammatikk, kan jeg ta feil på flere viktige områder.
;; - Ikke at jeg ønsker å implementere "Markdown" helt korrekt heller, siden deler av språket er merkelige greier.
;; 
;; Ting som er implementert:
;; - Overskrifter (De er det som nå blir tolket som horisontale linjer. H2 i alle fall.)
;; - kursiv, fet og understreket skrift
;; - lister
;; - akademiske henvisninger. (§sitering§?)
;; - fotnoter. (¤fotnote¤)
;; - sitater
;; - framtvinging av newlines.
;; - horisontale linjer
;; - ESCAPING \*happy\* skal ikke tolkes som (TAG happy), men som *happy*
;; - Håndtering av parenteser. () blir nå til \(\) i output.
;; - ## H2 ## Overskrifter
;; - paragrafer (Sjekk om vi har to whitespace linjer på rad, og hvis vi så har...)
;; 
;; Ting som skal implementeres:
;; DISSE BLIR GJORT NEST SIST!
;; - lenker (Kven veit heilt korleis? Og om det egentlig trengs?)
;; DISSE BLIR GJORT SIST! (må tenke på hvordan det henger sammen med resten av programmet)
;; - indentering av et dokument
;; - trimming av dokumentet (unødvendig mye plass tatt opp både foran og bak)
;; - mm!
;; - Mer formelle enhetstester er på tapetet.
;; Ting som *ikke* blir støttet:
;; - Bilder (bruk heller det overordnede predikatet for bilder!)
;; Merk at ting ikke er ferdig før det har i alle fall en enhetstest! Kan legges inn i *test-string-large*

					; Her er dependencies
(ql:quickload :cl-ppcre)
(ql:quickload :split-sequence)

(import 'CL-PPCRE:SCAN)
(import 'CL-PPCRE:SCAN-TO-STRINGS)
(import 'CL-PPCRE:REGEX-REPLACE)
(import 'CL-PPCRE:REGEX-REPLACE-ALL)
					; Testdata
(defparameter *test-string-large*
  "This is not a normal test string.
in fact, it has both /cursive/ words,
some _underlined_ words, and last but not least,
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

- - - - - - - - - - - - - - - - - - - - - - - 
And here are two lines!
 * * * * * * * * * * * * * * * * * * * * * * *
#### This is a level 4 header ####
And here is a level 1 header!
-----------------------------
Note that you only need 4 chars to make it a header.
     ====

 ### It does have links!

[Links look like this!](www.example.com \"eksempelnettsted\")
You can escape them by prepending '\\' characters on the brackets. Only one of the chars need to be escaped.
Escaping the parens has some weird bug in it.
\\[This is an escaped link](www.example.com \"eksempelnettsted\") and will not be made a URL

Please note that the current in-between language treats parens as magical characters unless escaped.
So if you want to use parens (like this!), you have to escape them with forward-slashes (\\)

## Here are some list examples ##
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

;;TODO: FJERN PRETTYPRINT FUNKSJONENE!
(defun prettyprint (stream object)
  (format stream "~A" object))

(defun prettyprint-line (stream object)
  (format stream "~%")
  (prettyprint stream object))

(defun remove-first-char (string)
  (subseq string 1))

(defun remove-last-char (string)
  (subseq string 0 (1- (length string))))

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
	     (incf current-line))
	(deal-with-no-list status stream "")))
    (remove-last-char (remove-first-char output-string))))

(defun open-tag (name stream)
  (format stream "(~A " name))

(defun close-tag (stream)
  (format stream ")"))

(defun remove-quote-stuff (line)
  (regex-replace "\\A\\s*>\\s+" line ""))

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
	      (prettyprint-line stream line))))
      (when inside-quotes
	(format stream ")")))
    (remove-first-char output-string)))

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
					; I guarantee you that there is a better regex for this than these two, but hug it.
	(horizontal-line-dash-regex "\\A\\s*(\\*\\s){3,}")
	(horizontal-line-star-regex "\\A\\s*(\\-\\s){3,}"))
    (with-output-to-string (stream output-string)
      (loop for line in (split-string-by-newlines input-string) do
	   (cond
	     ((or (scan horizontal-line-dash-regex line)
		  (scan horizontal-line-star-regex line))
	      (prettyprint-line stream "(HORIZONTAL-LINE)"))
	     ('NOT-MATCHING
	      (prettyprint-line stream line)))))
    (remove-first-char output-string)))


(defun interpret-dashy-and-equally-headline-rules (input-string)
  (let ((output-string (make-growable-string))
	(match-dashy-headline-regex "\\A\\s*\\-{4,}\\s*\\Z")
	(match-equal-headline-regex "\\A\\s*\\={4,}\\s*\\Z")
	(previous-line "")
	(first-iteration T))
    (with-output-to-string (stream output-string)
      (loop for line in (split-string-by-newlines input-string) do
	   (cond
	     ((scan match-dashy-headline-regex line)
	      (format stream "(HEADLINE :LEVEL \"1\" ~A)" previous-line)
	      (setf previous-line ""))
	     ((scan match-equal-headline-regex line)
	      (format stream "(HEADLINE :LEVEL \"2\" ~A)" previous-line)
	      (setf previous-line ""))
	     ('NO-HEADLINES
	      (unless first-iteration
		(format stream "~A~%" previous-line))
	      (setf previous-line line)))
	   (setf first-iteration nil))
      (format stream "~A" previous-line))
    output-string))

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
		(prettyprint-line stream line)))))
      (when currently-in-code-block 
	(format stream ")")))
    (remove-first-char output-string)))

(defun interpret-forced-newline-rules (input-string)
  "The newline in the string ruins the look of this function, but it works."
  (regex-replace-all "  (?=\\n|\\Z)"
		     input-string 
		     " (NEWLINE)"))


(defun string-headline-of-levelp (string level)
  (let ((regex (format 'nil "\\A\\s*#{~A}(?!#)" level)))
    (scan regex string)))

(defun remove-headline-markings (string level)
  (regex-replace (format 'nil "\\s*#{~A}\\s*\\Z" level)
		 (regex-replace (format 'nil "\\A\\s*#{~A}\\s*" level)
				string
				"")
		 ""))

(defun markdown-headline-to-middle-language (string level)
  (let ((output-string (make-growable-string)))
    (with-output-to-string (stream output-string)
      (format stream "(HEADLINE :LEVEL \"~A\" ~A)" level (remove-headline-markings string level)))
    output-string))

(defun make-hash-headline-rule (level)
  (lambda (string)
    (let ((output-string (make-growable-string)))
      (with-output-to-string (stream output-string)
	(loop for line in (split-string-by-newlines string) do
	     (cond
	       ((string-headline-of-levelp line level)
		(format stream "~A~%" (markdown-headline-to-middle-language line level)))
	       ('ELSE
		(format stream "~A~%" line)))))
      (remove-last-char output-string))))

(defun escape-parens (input-string)
  (regex-replace-all "\\)"
		     (regex-replace-all "\\(" input-string "\\(")
		     "\\)"))

(defun escape-slashes (input-string)
  "OBS! Må kjøres før escape-parens blir kalt!"
  (regex-replace-all "\\\\" input-string "\\\\\\\\"))

(defun interpret-escape-sequences (input-string)
  (escape-parens
   (escape-slashes
    input-string)))

(defun interpret-force-paragraph-rules (input-string)
  (let ((output-string (make-growable-string))
	(previous-line nil)
	(previous-write-was-new-paragraph nil))
    (with-output-to-string (stream output-string)
      (loop for line in (split-string-by-newlines input-string) do
	   (unless (null previous-line)
	     (cond
	       ((is-whitespace-linep previous-line)
		(unless previous-write-was-new-paragraph
		  (format stream "(NEW-PARAGRAPH)~%"))
		(setf previous-write-was-new-paragraph T))
	       ('NOT-WHITESPACE
		(format stream "~A~%" previous-line)
		(setf previous-write-was-new-paragraph NIL))))
	   (setf previous-line line))
      (format stream "~A~%" previous-line))
    (remove-last-char output-string)))

(defparameter *regex-string-literal*
  "\".*?(?<!\\\\)\"")
(defparameter *regex-brackets-pair*
  "(?<!\\\\)\\[.+?(?<!\\\\)\\]")
					; (?<!a)b

(defparameter *regex-match-url*
  "(?<!\\\\)\\[.+?\\]\\\\\\(.+?\\\\\\)")
;;en '[' så få ting som mulig før vi får en ']', før en '(' noen ting men så få som mulig, så en ')'

(defun interpret-link-literal (link-literal)
  "This function does not check if everything is okay or not. It utterly assumes that you know what you're doing and only pass in correct things.
interpret-link-literal will translate a link literal of the type: [link-name](url name) into (URL :ALT-NAME name :NAME link-name :URL url)
The order of operators is *not* guaranteed, only the existence of all three. They are listed here in alphabetical order."
  (let ((literal (copy-seq link-literal))
	(output-string (make-growable-string)))
    (with-output-to-string (stream output-string)
      (format stream "(URL")
      (let* ((navn-bit (remove-first-char (remove-last-char (scan-to-strings "\\[.*?\\]" literal))))
	     (url-og-alt (remove-last-char (remove-n-chars-from-string (+ (length navn-bit) 4) literal)))
	     (url-og-rest (split-sequence:SPLIT-SEQUENCE #\Space url-og-alt)))
	(format stream " :NAME ~A" (prin1-to-string navn-bit))
	(format stream " :URL ~A" (prin1-to-string (car url-og-rest)))
	(format stream " :ALT-NAME ~A" (prin1-to-string
					(format nil "~{~A~^ ~}" (cdr url-og-rest)))))
      (format stream ")"))
    output-string))

(defun interpret-url-rules (input-string)
  (let* ((string (copy-seq input-string)) ; to avoid clobbering the input-string
	 (output-string (make-growable-string))
	 (match-vals (multiple-value-list (scan *regex-match-url* string))))
    (with-output-to-string (stream output-string)
      (loop while (first match-vals) do
	 ;; write any string before we get to the match
	   (format stream "~a" (subseq string 0 (first match-vals)))
	 ;; write the parsed match
	   (format stream "~a" (interpret-link-literal (subseq string (first match-vals) (second match-vals))))
	 ;; setf the line to the rest of the string
	   (setf string (subseq string (second match-vals)))
;	   (setf match-vals (multiple-value-list (scan *regex-match-url* string)))
	   )
      ;;finally write the rest of the string
      (format stream "~a" string))
    output-string))



(defparameter *2urls* "'ere we go! [url1](www.example.com \"example1\") and second: [url2](www.example.com \"example2\") and donne.")

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
;(make-and-set-toggle-regex-rule "CURSIVE" "CURSIVE" "(?<!\\\\)\\/")

(set-rule "ESCAPE-SEQUENCES" #'interpret-escape-sequences)
(set-rule "ESCAPE-PARENS" #'escape-parens)
(set-rule "ESCAPE-SLASHES" #'escape-slashes)
(set-rule "URLS" #'interpret-url-rules)
(set-rule "HORIZONTAL-LINE" #'interpret-horizontal-line-rules)
(set-rule "LISTS" #'interpret-lists)
(set-rule "CODE-BLOCKS" #'interpret-code-literal-rules)
(set-rule "QUOTES" #'interpret-quotes)
(set-rule "PARAGRAPHS" #'interpret-force-paragraph-rules)
(set-rule "FORCED-NEWLINE" #'interpret-forced-newline-rules)
(set-rule "HASH-HEADLINE-1" (make-hash-headline-rule 1))
(set-rule "HASH-HEADLINE-2" (make-hash-headline-rule 2))
(set-rule "HASH-HEADLINE-3" (make-hash-headline-rule 3))
(set-rule "HASH-HEADLINE-4" (make-hash-headline-rule 4))
(set-rule "HASH-HEADLINE-5" (make-hash-headline-rule 5))
(set-rule "HASH-HEADLINE-6" (make-hash-headline-rule 6))
(set-rule "DASH-AND-EQUAL-HEADLINES" #'interpret-dashy-and-equally-headline-rules)

(defun compile-markdown-string (markdown-string)
  "Compiles a markdown string to the mid-level language.
Takes a string, and returns a string.
Does not change the original string in any way."
  (let ((output (copy-seq markdown-string)))
    (setf output (apply-rule "ESCAPE-SEQUENCES" output))
    (setf output (apply-rule "URLS" output))
    (setf output (apply-rule "HORIZONTAL-LINE" output))
    (setf output (apply-rule "DASH-AND-EQUAL-HEADLINES" output))
    (setf output (apply-rule "LISTS" output))
    (setf output (apply-rule "CODE-BLOCKS" output))
    (setf output (apply-rule "QUOTES" output))
    (setf output (apply-rule "HASH-HEADLINE-1" output))
    (setf output (apply-rule "HASH-HEADLINE-2" output))
    (setf output (apply-rule "HASH-HEADLINE-3" output))
    (setf output (apply-rule "HASH-HEADLINE-4" output))
    (setf output (apply-rule "HASH-HEADLINE-5" output))
    (setf output (apply-rule "HASH-HEADLINE-6" output))
;    (setf output (apply-rule "CURSIVE" output))
    (setf output (apply-rule "UNDERLINE" output))
    (setf output (apply-rule "FOOTNOTE" output))
    (setf output (apply-rule "CITE" output))
    (setf output (apply-rule "BOLD" output))
    (setf output (apply-rule "EMPHASISED" output))
    (setf output (apply-rule "FORCED-NEWLINE" output))
    (setf output (apply-rule "PARAGRAPHS" output))
    output))


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
;; 
;; Ting som skal implementeres:
;; - paragrafer (Sjekk om vi har to whitespace linjer på rad, og hvis vi så har...)
;; DISSE BLIR GJORT NEST SIST!
;; - lenker (Kven veit heilt korleis? Og om det egentlig trengs?)
;; DISSE BLIR GJORT SIST! (må tenke på hvordan det henger sammen med resten av programmet)
;; - indentering av et dokument
;; - trimming av dokumentet (unødvendig mye plass tatt opp både foran og bak)
;; - mm!
;; 
;; Ting som *ikke* blir støttet:
;; - Bilder (bruk heller det overordnede predikatet for bilder!)
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

- - - - - - - - - - - - - - - - - - - - - - - 
And here are two lines!
 * * * * * * * * * * * * * * * * * * * * * * *

#### This is a level 4 header ####

And here is a level 1 header!
-----------------------------

Note that you only need 4 chars to make it a header.
     ====

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

;;TODO: FJERN PRETTYPRINT FUNKSJONENE!
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
	      (format stream "(HEADLINE :LEVEL 1 ~A)" previous-line)
	      (setf previous-line ""))
	     ((scan match-equal-headline-regex line)
	      (format stream "(HEADLINE :LEVEL 2 ~A)" previous-line)
	      (setf previous-line ""))
	     ('NO-HEADLINES
	      (unless first-iteration
		(format stream "~A~%" previous-line))
	      (setf previous-line line)))
	   (setf first-iteration nil))
      (format stream "~A" previous-line))
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
	      (prettyprint-line stream line)))))
    (when currently-in-code-block 
      (format stream ")")))
    (remove-first-char output-string)))

(defun interpret-forced-newline-rules (input-string)
  "The newline in the string ruins the look of this function, but it works."
    (regex-replace-all "  (?=\\n|\\Z)"
		       input-string 
		       " (NEWLINE)"
		       ))


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
      (format stream "(HEADLINE :LEVEL ~A ~A)" level (remove-headline-markings string level)))
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
	       

(defun escape-slashes (input-string)
  "OBS! Må kjøres før escape-parens blir kalt!"
  (regex-replace-all "\\\\" input-string "\\\\\\\\"))

(defun interpret-escape-sequences (input-string)
  (escape-parens
   (escape-slashes
    input-string)))

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

(set-rule "ESCAPE-SEQUENCES" #'interpret-escape-sequences)
(set-rule "ESCAPE-PARENS" #'escape-parens)
(set-rule "ESCAPE-SLASHES" #'escape-slashes)
(set-rule "HORIZONTAL-LINE" #'interpret-horizontal-line-rules)
(set-rule "LISTS" #'interpret-lists)
(set-rule "CODE-BLOCKS" #'interpret-code-literal-rules)
(set-rule "QUOTES" #'interpret-quotes)
(set-rule "FORCED-NEWLINE" #'interpret-forced-newline-rules)
(set-rule "HASH-HEADLINE-1" (make-hash-headline-rule 1))
(set-rule "HASH-HEADLINE-2" (make-hash-headline-rule 2))
(set-rule "HASH-HEADLINE-3" (make-hash-headline-rule 3))
(set-rule "HASH-HEADLINE-4" (make-hash-headline-rule 4))
(set-rule "HASH-HEADLINE-5" (make-hash-headline-rule 5))
(set-rule "HASH-HEADLINE-6" (make-hash-headline-rule 6))
(set-rule "DASH-AND-EQUAL-HEADLINES" #'interpret-dashy-and-equally-headline-rules)

;; An ad-hoc unit-test, that runs all the rules, who have been added manually.
(defun run-all-the-rules! ()
  (let ((output (copy-seq *test-string-large*)))
    ;; We could just chain these calls, but it looks nicer when we setf them.
    ;; Notice that HORIZONTAL-LINE must run before LISTS
    ;; Interestingly, it should be okay if we run them in alphabetical order. ^_^
    (setf output (apply-rule "ESCAPE-SEQUENCES" output))
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
    (setf output (apply-rule "CURSIVE" output))
    (setf output (apply-rule "UNDERLINE" output))
    (setf output (apply-rule "FOOTNOTE" output))
    (setf output (apply-rule "CITE" output))
    (setf output (apply-rule "BOLD" output))
    (setf output (apply-rule "EMPHASISED" output))
    (setf output (apply-rule "FORCED-NEWLINE" output))
    output))

(defparameter *test-paragraphs*
  "This is how paragraphs should work:

This should create a new paragraph.
This should not.")

(defparameter *test-force-newlines*
  "This is how forcing newlines should work:
Two spaces on the end of a line like this:  
Forces a newline.  
However, this does not: 
Note the lack of newline?")

;; Sketching pad area for functions
(run-all-the-rules!)

(defparameter *test-hash-headline*
"   # Will Ye Go Lassie, Go? #

    ## Verse 1 ##
Oh, the summertime is coming
And the trees are sweetly blooming
And the wild mountain thyme
Grows around the blooming heather
Will ye go lassie, go?

    ## CHORUS ##
And we’ll all go together
To pluck wild mountain thyme
All around the blooming heather
Will ye go lassie, go?

    ## Verse 2 ##
I will build my love a bower
Near yon pure crystal fountain
And on it I will pile
All the flowers of the mountain
Will ye go lassie, go?

CHORUS

    ## Verse 3 ##
If my true love she were gone
I would surely find another
Where wild mountain thyme
Grows around the blooming heather
Will ye go lassie, go?

CHORUS

    ## Verse 4 ##
Oh, the summertime is coming
And the trees are sweetly blooming
And the wild mountain thyme
Grows around the blooming heather
Will ye go lassie, go?

CHORUS")

(defparameter *test-dash-and-equal-headlines*
"THIS IS A HEADLINE
------------------
And come tell me Sean O'Farrell tell me why you hurry so
Husha buachaill hush and listen and his cheeks were all a glow
I bare orders from the captain get you ready quick and soon
For the pikes must be together by the rising of the moon

CHORUS
======
    By the rising of the moon, by the rising of the moon
    For the pikes must be together by the rising of the moon

And come tell me Sean O'Farrell where the gath'rin is to be
At the old spot by the river quite well known to you and me
One more word for signal token whistle out the marchin' tune
With your pike upon your shoulder by the rising of the moon

By the rising of the moon, by the rising of the moon
With your pike upon your shoulder by the rising of the moon

Out from many a mud wall cabin eyes were watching through the night
Many a manly heart was beating for the blessed warning light
Murmurs rang along the valleys to the banshees lonely croon
And a thousand pikes were flashing by the rising of the moon

By the rising of the moon, by the rising of the moon
And a thousand pikes were flashing by the rising of the moon

All along that singing river that black mass of men was seen
High above their shining weapons flew their own beloved green
Death to every foe and traitor! Whistle out the marching tune
And hurrah, me boys, for freedom, 'tis the rising of the moon

'Tis the rising of the moon, 'tis the rising of the moon
And hurrah, me boys, for freedom, 'tis the rising of the moon")

(defparameter *test-forced-newlines*
"Her skal der være en tvungen newline:  
Her skal det ikke være en tvungen newline:
Her skal der være en igjen:  ")

(defparameter *test-emphasis*
"Emphasis looks is when you put stars around words, like \\*this\\*.
Escaping the stars with slashes '\\' removes the emphasis.
This is why *this* is emphasised, and \\*this\\* is not.")

(defparameter *test-bold*
"Bolded text is denoted by two underscores: \\_
So __this text is bolded__, and \\__this text is not\\__
Why is this text so __bold?__")

(defparameter *test-cite*
"You can cite things§Citatus55AD§ by using the \\§ characters to enclose a citation§Løtveit2014§.
Citing is very important for any good journal or scientific body of work§CaptObvious2006§.")

(defparameter *test-footnote*
"Footnotes are added by using the currency character.¤It looks like this: '\\¤'¤
I tend to overuse them¤No, really, I do!¤, because I like them too much.")

(defparameter *test-underline*
"You can underline things by using a _single_ underscore. (This character '\\_')
This is useful for emphasis, and making a bit of text stand out more.")

(defparameter *test-cursive*
"Cursive text is made by using the \\/ character. It may make you sound quite /mean/.
/Please be aware that people have used the cursive writing as a means to make snarky passive-aggressive comments about others.
You may want to avoid using it too much to not seem like a meanie./")

(defparameter *test-lists*
"A list of all the flaws in flawedtopia:
  - It's not perfect
  - It's rather not good, to be perfectly frank.
  - Frank didn't even like it.

A list of all the good bits of flawedtopia:
  1. The coffee was rather acceptable.
  1. The tea was not too expensive.
  4. The crumpets were excellent.")

(defparameter *test-escape-parens*
  "Hvis vi skal ha parenteser, må de escapes (ellers blir de tolket som kommandoer/tagger i midtspråket).
Derfor er det viktig at de blir escapet korrekt. \\(\\)")

(defparameter *test-code-blocks*
"Here are some code blocks:
    (defun greet-world ()
        (write-line \"Hello World!\"))
        (greet-world)")

(defparameter *test-quotations*
"> Implying you are a cat
> Implying you aren't just trying to steal my gains")

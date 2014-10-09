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
;; 
;; Ting som skal implementeres:
;; - Overskrifter
;; - kursiv, fet og understreket skrift
;; - horisontale linjer
;; - paragrafer
;; - lenker
;; - sitater
;; - blokksitater
;; - mm.?
;; 
;; Merk at ting ikke er ferdig før det har i alle fall en enhetstest!

(defvar *test-string-large*
"This is not a normal test string.
in fact, it has both /cursive/, _underlined_ and *bold* words.
Furthermore it has quotes:
> The problem with online citations is that it's hard to know if they are authentic or not.
> - Abraham Lincoln
And block quotes too:

    I see starts, etc.
    Blind Singing Man i good at singing.
    And this concludes the quote.

------------------------------------
And that was a line!")

(defun compile-string (string output-stream)
  (loop for line in (SPLIT-SEQUENCE:SPLIT-SEQUENCE #\N string) do
       (compile-line line output-stream)))

(defun compile-line (line output-stream)
  (let ((italic-state nil)
	(bold-state nil)
	(underlined-state nil)
	(block-quote-state nil))
    (format output-stream "~A" (prin1-to-string line))))

(compile-string *test-string-large* *standard-output*)

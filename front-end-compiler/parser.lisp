(load (merge-pathnames "front-end-compiler/compilation-unit-classes.lisp" *default-pathname-defaults*))

#|
 | Syntaks:
 | ($NAVN-PÅ-INNHOLDSTYPE :KOLON-SOM-TAG "$STRENGVERDI")
 | Der navn på innholdstype er tekst uten whitespace, kolon-tags er : + tekst uten whitespace og strengverdi er standard strenger med escaping som vi kjenner dem fra ca. alle språk.
 | Støttede typer:
 | Markdown - :fil "sti-til-filen"
 | Bilde - :fil "sti-til-filen"
 | Tabell - :fil "sti-til-filen"
 | Direkte-innsatt-tekst - :fil "sti-til-filen"
 | rentekst - :fil "sti-til-filen
 |#

(defvar *FEC-OUTPUT-STREAM* *STANDARD-OUTPUT*) ; Hack for å slippe å gi inn denne som argument. Blir midlertidig ombundet av kompileringskallet.

(defun fec-remove-comments (string)
  "Removes comments from fec-source"
  (let ((textlist (coerce string 'list)))
    (labels ((outside (list)
	       (cond
		 ((null list)
		  nil)
		 ((char= #\; (car list))
		  (inside (cdr list)))
		 ('ELSE
		  (cons (car list) (outside (cdr list))))))
	     (inside (list)
	       (cond
		 ((null list)
		  nil)
		 ((char= #\Newline (car list))
		  (outside list))
		 ('else (inside (cdr list))))))
      (coerce (outside textlist) 'string))))
		     
(let ((teststring (concatenate 'string
			       "This is a teststring ;This is a comment" +nl+
			       "We want to see if comments are removed properly."))
      (expected   (concatenate 'string
			       "This is a teststring " +nl+
			       "We want to see if comments are removed properly.")))
  (unless (string= expected (fec-remove-comments teststring))
    (error "Function fec-remove-comments in parser.lisp does not work properly")))

(defun fec-remove-empty-lines (string)
  (reduce (lambda (x y)
	    (let ((left-empty-p (scan "^\\s*$" x))
		  (rigt-empty-p (scan "^\\s*$" y)))
	      (cond
		((and left-empty-p rigt-empty-p)
		 "")
		(left-empty-p y)
		(rigt-empty-p x)
		('NEITHER-IS-EMPTY
		 (concatenate 'string x +nl+ y)))))
	      
	  (SPLIT-SEQUENCE:SPLIT-SEQUENCE #\Newline string)))

(let ((teststring (concatenate 'string
			       "Teststring:" +nl+
			       +nl+ +nl+
			       "     " +nl+
			       "Should only be two lines"))
      (expected   (concatenate 'string
			       "Teststring:" +nl+
			       "Should only be two lines")))
  (unless (string= expected (fec-remove-empty-lines teststring))
    (error "Function fec-remove-empty-lines in parser.lisp does not work properly")))

(defun fec-compile-file (source-file output-file)
  (with-open-file (*FEC-OUTPUT-STREAM* output-file :direction :output :if-does-not-exist :create :if-exists :overwrite)
    (let ((contents (SPLIT-SEQUENCE:SPLIT-SEQUENCE #\Newline (fec-remove-empty-lines (fec-remove-comments (slurp-file source-file))))))
      (loop for command in contents do
   	   (eval (read-from-string command))))))

(defun bilde (&key fil)
  (format *FEC-OUTPUT-STREAM* "(IMAGE :FILE \"~A)\"" fil))

(defun fec-text-compile (package file)
  (setf (gethash "fil" (fields package)) file)
  (compile-package package))

(defun markdown (&key fil)
  (fec-text-compile (make-instance 'markdown-package :destination-stream *FEC-OUTPUT-STREAM*) fil))
  
(defun uformattert (&key fil)
  (fec-text-compile (make-instance 'no-markup-text-package :destination-stream *FEC-OUTPUT-STREAM*) fil))

(defun direkte-insatt (&key fil)
  (fec-text-compile (make-instance 'directly-inserted-text-package :destination-stream *FEC-OUTPUT-STREAM*) fil))

(defun tabell (&key fil (første-linje-er-tabellnavn "nei"))
  (let ((package (make-instance 'table-compilation-package :destination-stream *FEC-OUTPUT-STREAM*)))
    (setf (gethash "første-linje-er-tabellnavn" (fields package)) første-linje-er-tabellnavn)
    (setf (gethash "fil" (fields package)) fil)
    (compile-package package)))


(fec-compile-file "~/git/Masteroppgave/front-end-compiler/testdata/test-dokument.aura" "~/virker.mfo")


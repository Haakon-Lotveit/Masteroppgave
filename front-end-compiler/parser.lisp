#|
 | Hvordan dette skal i teorien fungere.
 | 1: Dette blir en (venstre) rekursiv parser, selv om språket i teorien skal være regulært.
 | 2: Parseren forstår følgende entiteter (preprosessordirektiver blir ikke håndtert av parseren):
 |   - Preludium (navn kan endres):
 |     preprosesseringsdirektiver, brukes for å oppdatere funksjoner, etc.
 |     På denne måten kan en utvide språket.
 |     Hvilke underkategorier som er lov er ikke bestemt.
 |
 |   - Dokument: Markerer begynnelsen på dokumentet i sin propre form.
 |   - Tekst: Markerer en tekstbolk som skal brukes.
 |     Lovlige argumenter er:
 |      × fil=[streng]
 |      × sitat=[streng]
 |      × type=[markdown|uformattert|direkte-innsatt]
 |
 |   - Bilde: Markerer et bilde som skal brukes.
 |     Lovlige argumenter er:
 |      × fil=[streng]
 |      × etter-kall=[streng]
 |      × plassering=[streng]
 |      × skalering=[streng]
 |     Merk at en krever en fil for bilder.
 |
 |   - Tabell: Markerer en tabell som skal brukes.
 |     Lovlige argumenter er ikke enda fullført, men en tentativ liste er:
 |      × første-linje-er-tabellnavn=["ja"/"nei"] (om ikke oppgitt er standardverdi "nei")
 |      × kolonnenavn=[string] (Ikke bestemt hvordan skal fungere. Vil kreve at første-linje-er-tabellnavn er satt til "nei").
 |      × tekst-stilling[string] (Ikke bestemt hvordan skal fungere. Antar LaTeX måte å gjøre det på med l c og r.)
 |
 |   - Programkall: Markerer en systemkommando som skal kjøres.
 |      × kommando=[Streng]
 |
 | 3: Parseren tar ikke i Preludium på noen måter, men hopper over den.
 |    Preludium er kun for preprosessoren, og det kreves at preprosessoren fjerner den.
 | 
 | 4: Parseren begynner ikke å parse før den når Dokumenter. Hvis den ser noe som helst tekst FØR Dokumenter, er det en feil som skal varsles.
 |
 | 5: For hver entitet inni dokument som er lovlig, vil parseren:
 |   - opprette et map med alle argumentene i. For eksempel vil fil="~/Bilder/bilde.png" bli lagret med nøkkel "fil" og verdi "~/Bilder/bilde.png"
 |   - fore mappet videre til front-end kompilatoren etter hvert som den blir ferdig.
 |   - dersom ulovlige verdier, el. blir oppdaget vil parseren kaste en error av et slag.
 |   - dersom parseren ikke når en verdig slutt, vil den kaste en error istedenfor å dø.
 |
 | 6: Når parseren er ferdig, nullstiller den en evt. state i kompilatoren.
 |#

(load (merge-pathnames "front-end-compiler/compilation-unit-classes.lisp" *default-pathname-defaults*))


(defvar *test-tokens* '("Dokument:" "Bilde:" "fil=\"~/Bilder/bilde.png\"" "." "."))

(defun legg-til-par (par hash-table)
  "et par er av typen [navn]=[streng], og skal puttes inn i et gitt hash-table med navn som nøkkel og streng som verdi"
  (let*
      ((pos (position #\= par))
       (key (subseq par 0 pos))
       (val (read-from-string (subseq par (1+ pos)))))
    (setf (gethash key hash-table) val))
  hash-table)

;; Reads arguments of the form "[VAR]=[VALUE], separated by space, until it reaches a token that's equal to "."
;; Then it returns the hashmap it has read.
(defun collect-arguments (arglist)
  (cond ((string= "." (car arglist))
	 (list (make-hash-table :test 'equal) (cdr arglist)))
	
	('else
	 (let* ((recursive-call (collect-arguments (cdr arglist)))
		(map (first recursive-call)))
	   (legg-til-par (car arglist) map) ;; Dette muterer state
	   recursive-call))))
;; unit test for collect-arguments
(let* ((result (collect-arguments '("a=\"alfa\"" "b=\"bravo\"" "." "c=\"charlie\"")))
       (map (first result))
       (rest-list (second result))
       (forventet-rest '("c=\"charlie\"")))
  (test #'string= "alfa" (gethash "a" map))
  (test #'string= "bravo" (gethash "b" map))
  (test #'equal nil (gethash "c" map))
  (test #'equal forventet-rest rest-list)
  T)

(defun dokument-parsefun (stream arglist)
  "Opens a document, quick hack that doesn't recursively parse, which should be fixed in the future."
  (compile-package (make-instance 'start-document
				  :destination-stream stream))
  arglist) ;; We don't touch the arglist, we just send it back.

(defun bilde-parsefun (stream arglist)
  (let* ((collection (collect-arguments arglist))
	 (fields (first collection))
	 (rest-list (second collection)))
    (compile-package (make-instance 'image-compilation-package
				    :fields fields
				    :destination-stream stream))
    rest-list))

(defun markdown-parsefun (stream fields)
    (compile-package (make-instance 'markdown-package
				 :fields fields
				 :destination-stream stream)))

;; (defun generic-text-parsefun (stream arglist)
;;   "Deals with the various types of text"
;;   (let* ((collection (collect-arguments arglist))
;; 	 (fields     (first collection))
;; 	 (rest-list  (second collection))
;; 	 (type       (gethash "type" fields "UNKNOWN-TYPE")))
;;     (cond 
;;       ((string= type "markdown")
;;        markdown)
;;       ((string= type "uformattert")
;;        uformattert)
;;       ((string= type "direkte-innsatt")
;;        direkte-innsatt)
;;       ('DEFAULT
;;        (error (format 'nil "Text type ~A is not recognized"))))
;;     rest-list))

;; (let ((arglist '("fil=\"~/textfile.text\"" "type=\"markdown\"" "." ".")))
;;   (generic-text-parsefun *standard-output* arglist))

(defun end-parsefun (stream arglist)
  (format stream ")")
  arglist)

(defvar *parsing-functions*
  (progn
    (let ((funmap (make-hash-table :test 'equal)))
      (setf (gethash "Dokument:" funmap)
	    #'dokument-parsefun)
      (setf (gethash "Bilde:" funmap)
	    #'bilde-parsefun)
      (setf (gethash "." funmap)
	    #'end-parsefun)
      funmap)))

(defun parse-en-ting (parse-list stream)
  (unless (gethash (car parse-list) *parsing-functions*)
    (error (format 'nil "Kunne ikke parse token \"~A\"." (car parse-list))))
  (let ((rest-list (funcall (gethash (car parse-list) *parsing-functions*)
			    stream
			    (cdr parse-list))))
    rest-list))

(defun parse-help (parse-list stream)
  (unless (null parse-list)
    (parse-help (parse-en-ting parse-list stream) stream)))

(defun parse (tokenlist stream)
  (let ((*indentation-level* 0))
    (parse-help tokenlist stream)))

;; enhetstest for funksjonen "parse".
;; tester implisitt hjelpefunksjoner.
(let* ((parse-output (make-growable-string))
       (expected (concatenate 'string
			      +nl+ "(dokument" 
			      +nl+ "    (bilde :fil ~/Bilder/bilde.png))")))
  (with-output-to-string (string-stream parse-output)
    (parse *test-tokens* string-stream))
  (test #'string= expected parse-output "Test for function \"parse\""))


  

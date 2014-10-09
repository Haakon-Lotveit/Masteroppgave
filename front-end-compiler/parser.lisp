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

(load "auxiliary-functions.lisp")
(load "compilation-unit-classes.lisp")
(defvar *test-tokens* '("Dokument:" "Bilde:" "fil=\"~/Bilder/bilde.png\"" "." "."))

(defun legg-til-par (par hash-table)
  "et par er av typen [navn]=[streng], og skal puttes inn i et gitt hash-table med navn som nøkkel og streng som verdi"
  (let*
      ((pos (position #\= par))
       (key (subseq par 0 pos))
       (val (read-from-string (subseq par (1+ pos)))))
    (setf (gethash key hash-table) val))
  hash-table)

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
(defvar *parsing-functions*
  (progn
    (let ((funmap (make-hash-table :test 'equal)))
      
      (setf (gethash "Dokument:" funmap)
	    (lambda (stream arglist)
	      "Åpner et dokument. I framtiden burde den rekursivt parse resten, men akkurat nå er dette en kjapp hack. Krever manuell lukking."
	      (compile-package (make-instance 'start-document
					      :destination-stream stream))
	      arglist))
      
      (setf (gethash "Bilde:" funmap)
	    (lambda (stream arglist)
	      (let* ((collection (collect-arguments arglist))
		     (fields (first collection))
		     (rest-list (second collection)))
		(compile-package (make-instance 'image-compilation-package
						:fields fields
						:destination-stream stream))
		rest-list)))
      
      (setf (gethash "." funmap)
	    (lambda (stream arglist)
	      "Sørger for manuell lukking av Dokument: tokener"
	      (format stream ")")
	      arglist))
      
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
       (nl '(#\Newline)) ; TODO: Det må finnes en "join" funksjon i Common Lisp et sted?
       (expected (concatenate 'string
			      nl "(dokument" 
			      nl "    (bilde"
			      nl "        :fil ~/Bilder/bilde.png))")))
  (with-output-to-string (string-stream parse-output)
    (parse *test-tokens* string-stream))
  (test #'string= expected parse-output "Test for function \"parse\""))

  

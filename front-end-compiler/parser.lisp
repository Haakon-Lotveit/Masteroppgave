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
 |     Lovlige argumenter og slikt er ikke enda definert.
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
 |   - Programkall: Markerer en systemkommando som skal kjøres. Eneste argumentet er en streng som beskriver kommandoen.
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

(load "compiler.lisp") ;; TODO: Set up ASDF etc.
(load "compilation-unit-classes.lisp")

(defvar *test-tokens* '("Dokument:" "Bilde:" "fil=\"~/Bilder/bilde.png\"" "." "."))

(defvar *parser-function-table* (make-hash-table))
(defun set-parser-function-table (emit-function)
  (setq *parser-function-table* (make-hash-table))

  ;; Sets up functions wrapping over the emit-function, etc.
  ;; This will be closed over by the function.
  (flet ((start-block (block-name) (funcall #'start-block emit-function block-name))
	 (end-block () (funcall #'end-block emit-function))
	 (add-item (key item) (funcall #'add-item
				       :emit-function emit-function
				       :item item
				       :escape-string T
				       :key key))
	 (newline () (funcall emit-function #\Newline))
	 (space () (funcall emit-function #\Space))
	 (increase-indentation () (incf *indentation-level*))
	 (decrease-indentation () (decf *indentation-level*))
	 (indent () (dotimes (i (indentation-spaces)) (funcall emit-function #\Space))))

    (setf (gethash "Dokument:" *parser-function-table*)
	  (lambda (token-list )
	    (start-block "document")
	    (increase-indentation)))

    ))

(defvar *tokens* (make-hash-table :test 'equal))
(defun nullstill-lovlige-tokens ()
  (setq *tokens*
	(make-hash-table :test 'equal))
  (setf (gethash "Bilde:" *tokens*)
	'("fil" "etter-kall" "plassering" "skalering"))
  (setf (gethash "Tabell:" *tokens*)
	'(""))
  (setf (gethash "Tekst:" *tokens*)
	'(""))
  (setf (gethash "Dokument:" *tokens*) T)
  (setf (gethash "." *tokens*) nil)
  *tokens*)

(defun legal-entity-name (entity-name)
  (gethash entity-name *tokens*))

(defun legal-entity-value (entity-name value-name)
  (member value-name
	  (gethash entity-name *tokens*)
	  :test #'string=))

(defun legal-argument-string (argument)
  (stringp argument))

(defun legal-argument-ja/nei (argument)
  (or (string= argument "ja")
      (string= argument "nei")))

(defun parse-help (tokenlist)
  (print tokenlist)
  (cond ((endp tokenlist) (format 'T "FERDIG!~%"))
	((legal-entity-name (car tokenlist))
	 (parse-help (funcall (gethash (car tokenlist) *parser-function-table*) tokenlist)))
	('ELSE (error (format 'nil "Couldn't figure out how to parse \"~A\" properly." (car tokenlist))))))


(defun parse (tokenlist)
  (unless (string= "Dokument:" (car tokenlist))
    (error (format 'nil "Dokumentet begynner ikke med \"Dokument:\", men med \"~A\"." (car tokenlist))))
  (parse-help tokenlist))


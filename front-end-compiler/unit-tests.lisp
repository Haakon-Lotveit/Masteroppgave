(format 't "Tester enheter for:~%Tabeller: ~A~%Bilder:   ~A~%"
	(test-compilation-unit-compile
	 (make-instance 'table-compilation-package
			:fields   (make-hash-table-from-list
				   '(("fil" "front-end-compiler/exampledata/small-table.csv")
				     ("første-linje-er-tabellnavn" "ja"))))
	 (concatenate 'string
		      +nl+
		      "(tabell
    (row (header \"fruit name\") (header \"price per kg\") (header \"db id\"))
    (row (data \"apple\") (data \"14,90\") (data \"1\"))
    (row (data \"banana\") (data \"12,40\") (data \"2\"))
    (row (data \"cumquat\") (data \"22,99\") (data \"3\"))
    (row (data \"dates\") (data \"49,90\") (data \"4\"))
    (row (data \"elderberries\") (data \"39,90\") (data \"5\"))
    (row (data \"figs\") (data \"54,49\") (data \"6\"))
    (row (data \"grapes\") (data \"25,90\") (data \"7\"))
    (row (data \"harlots\") (data \"9,90\") (data \"8\")))"))

	;; Tester at bilder kompileres korrekt
	(test-compilation-unit-compile 
	 (make-instance 'image-compilation-package 
			:fields (make-hash-table-from-list 
				 '(("fil" "~/Bilder/bilde.png")
				   ("location" "centered")
				   ("size" "50%"))))
	 (concatenate 'string +nl+ "(bilde :fil ~/Bilder/bilde.png :location centered :size 50%)")))

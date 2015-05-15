(format 't "Tester enheter for:~%Tabeller: ~A~%Bilder:   ~A~%"
	(test-compilation-unit-compile
	 (make-instance 'table-compilation-package
			:fields   (make-hash-table-from-list
				   '(("fil" "front-end-compiler/exampledata/small-table.csv")
				     ("første-linje-er-tabellnavn" "ja"))))
	 (concatenate 'string
		      +nl+
		      "(TABELL :SIZE \"3\" :HEADERS \"yes\"
    (ROW (HEADER fruit name) (HEADER price per kg) (HEADER db id))
    (ROW (DATA apple) (DATA 14,90) (DATA 1))
    (ROW (DATA banana) (DATA 12,40) (DATA 2))
    (ROW (DATA cumquat) (DATA 22,99) (DATA 3))
    (ROW (DATA dates) (DATA 49,90) (DATA 4))
    (ROW (DATA elderberries) (DATA 39,90) (DATA 5))
    (ROW (DATA figs) (DATA 54,49) (DATA 6))
    (ROW (DATA grapes) (DATA 25,90) (DATA 7))
    (ROW (DATA harlots) (DATA 9,90) (DATA 8)))"))

	;; Tester at bilder kompileres korrekt
	(test-compilation-unit-compile 
	 (make-instance 'image-compilation-package 
			:fields (make-hash-table-from-list 
				 '(("fil" "~/Bilder/bilde.png")
				   ("location" "centered")
				   ("size" "50%"))))
	 (concatenate 'string +nl+ "(bilde :fil ~/Bilder/bilde.png :location centered :size 50%)")))

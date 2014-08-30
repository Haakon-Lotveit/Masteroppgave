;; Since this is run through a lisp-reader (I haven' decided which dialect yet though)
;; You can add comments, edit by hand, etc. as much as you'd like.
;; This is a simple example of what the intermediary step should look like.
;; It is then supposed to be compiled down to other formats.
;; For instance LaTeX, HTML, DocBook, completely normal text, etc.
;; The entire idea is to have the front end producing this by running its programs, etc.
;; Then feed this into one or more back-ends 
(document
 (prelude
  (define front-page (include-doc "front-page.lisp"))))
(front-page)
(header 1 (text :normal :font-size :large :font :sans-serif
		"This is an example document"))
(paragraph (text :normal :font-size :medium :font :serif
		 "This parse-tree is intended as an eksample of how to do things."
		 "The text field consists of definitions on top, and then n strings."
		 "Text breaking and similar is left to the back-end compiler."
		 "If you want to hack on a parse-tree yourself, consider looking over "
		 "the documentation for the syntax. Not just the EBNF, "
		 "but also the more practical docs."
		 "You can give commands such as asking for new-lines by embedding"
		 " a newline by using the (newline) command or the (nl) shorthand."
		 (newline)
		 "This should be used only where it makes sense, as the backend compilers"
		 " should be more than capable of dealing with this sort of thing.")
	   (image :location :centered :size :% 50
		  "images/exampleimage.png")
	   (text :normal :font-size :medium :font :serif
		 "You can embed images as well, although the precise nature of "
		 "how they'll work is left as work to be done later."))
(paragraph (text :normal :font "Ubuntu Condenced" :size :pt 12
		 "You can specify fonts etc. although the compiler can ignore things it cannot process."
		 "For instance, a back-end compiler that produces plain-text emails would not be able to "
		 "deal with fonts, as it doesn't have any concept of such a thing."))

(header 1 (text :normal :font-size :large :font :sans-serif
		"You can specify more than just text"))

(paragraph (text :normal
		 "You can also specify less and let the compiler choose the standards. "
		 "I hope that this short file is readable, even in source form. "
		 "It does look quite nice in Emacs' lisp mode, even more-so than LaTeX. ")))



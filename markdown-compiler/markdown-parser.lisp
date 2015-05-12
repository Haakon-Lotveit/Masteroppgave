;; See markdown.lisp for more documentation. This is a simple rewrite that does things more properly.

This is the first function to be rewritten.
It will handle parsing out paired markers, such as *this* for bolded letters.
For instance, the string "This is *bolded* text" should parse into:
("This is " (bold "bolded") " text") when the function is called like:
(parse-out-pairs #\* "bold" "This is *bolded* text")

(defun parse-out-pairs (pair-char expression-name string)

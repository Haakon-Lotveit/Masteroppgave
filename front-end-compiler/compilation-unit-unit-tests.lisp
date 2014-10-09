(quicklisp:quickload "clunit")

(defun make-adjustable-string ()
  (make-array '(0)
	      :element-type 'base-char
	      :fill-pointer 0
	      :adjustable t))

(defun diffposs (left right)
  (let ((ans -1))
    (dotimes (i (min (length left) (length right)))
      (when (not (equal (elt left i)
			(elt right i)))
	(setf ans i)
	(return)))
    ans))
(defun test-compilation-unit-compile (compilation-unit expected-output)
  (let* ((actual-output (test-compile-to-string compilation-unit))
	 (success (string= expected-output actual-output)))
      (if success
	  (format 'NIL "")
	  (format 'NIL (concatenate 'string
				    "+---------+~%"
				    "| Lengde: |~%"
				    "+---------+~%"
				    "Expected: ~A~%"
				    "  Actual: ~A~%"
				    "+--------------------------+~%"
				    "|Difference started at: ~A |~%"
				    "+--------------------------|~%"
				    "+---------+~%"
				    "|Expected:|~%"
				    "+---------+~%"
				    "~A~%"
				    "+---------+~%"
				    "| Actual: |~%"
				    "+---------+~%"
				    "~A~%")
		  (length expected-output)
		  (length actual-output)
		  (diffposs expected-output actual-output)
		  (prin1-to-string expected-output)
		  (prin1-to-string actual-output)))))



(defun test-compile-to-string (compilation-unit)
  (let ((output (make-adjustable-string))
	(original-output-stream (destination-stream compilation-unit)))
    (with-output-to-string (output-stream output)
      (setf (destination-stream compilation-unit) output-stream)
      (compile-package compilation-unit))
    (setf (destination-stream compilation-unit) original-output-stream)
    output))
    

;; Tilsvarer det som bor i *table-hashmap*
(defvar *standard-table-result*
  "(table
    (row (header \"fruit name\") (header \"price per kg\") (header \"db id\"))
    (row (data \"apple\") (data \"14,90\") (data \"1\"))
    (row (data \"banana\") (data \"12,40\") (data \"2\"))
    (row (data \"cumquat\") (data \"22,99\") (data \"3\"))
    (row (data \"dates\") (data \"49,90\") (data \"4\"))
    (row (data \"elderberries\") (data \"39,90\") (data \"5\"))
    (row (data \"figs\") (data \"54,49\") (data \"6\"))
    (row (data \"grapes\") (data \"25,90\") (data \"7\"))
    (row (data \"harlots\") (data \"9,90\") (data \"8\")))
")

;; Tilsvarer det som bor i *image-hashmap*)
(defvar *standard-image-result*
"(image
     :fil ~/Bilder/bilde.png
     :location centered
     :size 50%)
")

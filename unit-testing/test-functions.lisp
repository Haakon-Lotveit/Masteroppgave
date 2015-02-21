(defun test-compile-to-string (compilation-unit)
  (let ((output (make-growable-string))
	(original-output-stream (destination-stream compilation-unit)))
    (with-output-to-string (output-stream output)
      (setf (destination-stream compilation-unit) output-stream)
      (compile-package compilation-unit))
    (setf (destination-stream compilation-unit) original-output-stream)
    output))

(defun diffposs (left right)
  "Returns the location where the first character differs between the two strings.
If the strings are equal, then -1 is returned."
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
 

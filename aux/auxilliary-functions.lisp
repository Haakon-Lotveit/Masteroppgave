;;; Contains auxiliary functions to make testing etc. simpler to do.
(defun make-hash-table-from-list (pair-list)
  (let ((hash (make-hash-table :test 'equal)))
    (loop for pair in pair-list do
	 (setf (gethash (first pair) hash) (second pair)))
    hash))

(defun make-growable-string ()
  (make-array '(0)
	      :element-type 'extended-char
	      :adjustable 't
	      :fill-pointer 0))

(defun test (testfun expected actual &optional (test-name "test"))
  (unless (funcall testfun expected actual)
    (error "~A failed:~%Expected:~%~A~%Actual:~%~A~%" test-name expected actual))
  T)

(defun slurp-stream (stream)
  (let ((seq (make-array (file-length stream) :element-type 'character :fill-pointer t)))
    (setf (fill-pointer seq) (read-sequence seq stream))
    seq))

(defun slurp-file (filespec)
  (with-open-file (filestream filespec)
    (slurp-stream filestream)))

(defconstant +nl+ '(#\Newline))

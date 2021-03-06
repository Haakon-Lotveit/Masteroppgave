;;; A basic tokeniser for my master's thesis
;;; Known limitations:
;;;  - whitespace and stop-symbols is just that, symbols only.
;;;  - State is encapsulated in global state, instead of using a class and a generic method tokenise
;;;
;;; It does however, parse correctly and handle string-literals, stop symbols, and escaped characters inside string literals.
;;; State may be encapsulated in an object at a later date, but I do not see any reason to let stop-symbols and whitespace
;;; be more than one character long, since the language it is used for does not have stop-words and whitespace-words.

(defvar *eksempelstring* "Bilder: file=\"Mine Bilder/\\\"reapers\\\".png\".")

(defun produce-standard-escape-map ()
  (let ((escape-map (make-hash-table :test 'equal)))
    (dolist (pair '((#\" #\")
		    (#\n #\Newline)
		    (#\t #\Tab)
		    (#\r #\Return)))
      (setf (gethash (car pair) escape-map) (cadr pair)))
    escape-map))

(defvar *escape-map* (produce-standard-escape-map))

(defun get-escaped-char (char)
  (gethash char *escape-map*))

(defvar *whitespace*
  (list #\Space #\Return #\Newline #\Tab #\No-Break_Space))
(defvar *stop-symbols*
  (list #\.))

;; Takes a large string and tokenizes it.
(defun tokenize (string)
  (let ((inside-literal nil)
	(acc ())
	(tegn #\Space)
	(tokens ()))
    (flet ((empty-acc ()
	     (when (not (equal () acc))
	       (push (concatenate 'string (reverse acc)) tokens)
	       (setf acc ())))
	   (add-char (char)
	     (push char acc))
	   (cross-literal-boundary ()
	     (setf inside-literal (not inside-literal)))
	   (whitespacep ()
	     (member tegn *whitespace*))
	   (stop-symbolp ()
	     (member tegn *stop-symbols*)))
      (dotimes (i (length string))
	(setf tegn (char string i))
	(cond ((equal #\" tegn)
	       (add-char tegn)
	       (cross-literal-boundary))
	      ((and (whitespacep) (not inside-literal))
	       (empty-acc))
	      ((and (stop-symbolp) (not inside-literal))
	       (empty-acc) (add-char tegn) (empty-acc))
	      ((and (equal #\\ tegn) inside-literal)
	       (add-char (get-escaped-char (char string (1+ i))))
	       (incf i))
	      ('ELSE (add-char tegn))))
      (empty-acc)
      (reverse tokens))))

;; Takes a filespec and returns a list of tokens from that file.
(defun tokenize-file (filename)
  (with-open-file (filestream filename :direction :input)
    (let ((seq (make-string (file-length filestream))))
      (read-sequence seq filestream)
      (tokenize seq))))

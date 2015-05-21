#!/usr/bin/sbcl --script
;; This is the file that is used for starting up on UNIX™ systems.

(defun print-hash-table (hash-table)
  (loop for key being the hash-keys of hash-table do
       (format T "~A →  ~A~%" key (gethash key hash-table))))

(defun begins-with (element string)
  (unless (> (length element) (length string))
    (let* ((len (length element))
	   (beg (subseq string 0 len)))
      (string= element beg))))

(defun put-option-argv-in-hash-table (hash-table argv option)
  (flet ((remove-last-char (string)
	   (subseq string 0 (1- (length string)))))
    (let ((len (length option))
	  (command-name (subseq option 2)))
      (setf (gethash (remove-last-char command-name) hash-table)
	    (subseq argv len))
      hash-table)))
	  

(defun get-option (ht option-name)
     (loop for argv in *posix-argv* do
	 (when (begins-with option-name argv)
	   (put-option-argv-in-hash-table ht 
					  argv 
					  option-name))))
	        
(defun parse-command-lines ()
  "This simplistic function parses out command lines and returns a hash-table with them in." ;; A better idea would be to use an object, but I have little time.
  (let ((hash-table (make-hash-table :test 'equal)))
    (get-option hash-table "--input-file=")
    (get-option hash-table "--output-file=")
    (get-option hash-table "--compiler=")
    hash-table))

(defun start ()
  "Start is the entry point to the application, will run the program and then exit.
Note that it is currently not functional."
  (let ((parsed-command-lines (parse-command-lines)))
    (format t "~%Loading system...~%")
    (load "Main.lisp")
    (format t "~%System loaded~%")
    (glue-compile-stuff-from-hash-table parsed-command-lines))
    
  (exit :code 0))

(start)

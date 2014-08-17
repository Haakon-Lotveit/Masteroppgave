;;; Front end compiler for the project
;;; Currently everything here is a sketch, and nothing is final.

;;; There are four main things that have to be defined here:
;;;  - How to insert text (plain, markdown or others)
;;;  - How to insert lists (ordered, unordered) (This may be redone as a part of text editing)
;;;  - How to insert tables (two dimensional ones, from CSV only) (kind of done)
;;;  - How to insert images (kind of done)

;;; In addition to this, an abstraction facility must be made available to let
;;; the users create their own rules that extend on the above four things.

(quicklisp:quickload "cl-csv")
(defun load-settings (settings-file)
  

(defun emit (item)
  (format 'T "~A" item))

(defun compile-csv (input-stream emit-function indentation-level spaces-per-indent first-line-is-header)
  (let ((indentation-spaces (* indentation-level spaces-per-indent)) 
	(print-headers first-line-is-header))
    
    (flet ((start-block (block-name) (funcall #'start-block emit-function block-name))
	   (end-block () (funcall #'end-block emit-function))
	   (add-item (key item) (funcall #'add-item
				 :emit-function emit-function
				 :item item
				 :escape-string T
				 :key key))
	   (newline () (funcall emit-function #\Newline))
	   (space () (funcall emit-function #\Space))
	   (increase-indentation () (incf indentation-spaces spaces-per-indent))
	   (decrease-indentation () (decf indentation-spaces spaces-per-indent))
	   (indent () (dotimes (i indentation-spaces) (funcall emit-function #\Space))))
      
      (indent)
      (start-block "table")
      (increase-indentation)
      (loop for line in (cl-csv:read-csv input-stream) do
	   (newline)
	   (indent)
	   (start-block "row")
	   (loop for item in line do
		(space)
		(if print-headers
		    (start-block "header")
		    (start-block "item"))
		(add-item nil item)
		(end-block))
	   (setf print-headers 'nil)
	   (end-block))
      (decrease-indentation)
      (end-block)
      (newline))))

(defun compile-image (image-path emit-function indentation-level spaces-per-indent)
  (let ((indentation-spaces (* indentation-level spaces-per-indent))
	(absolute-path-spec (namestring (car (directory (pathname image-path))))))
    (flet ((start-block (block-name) (funcall #'start-block emit-function block-name))
	   (end-block () (funcall #'end-block emit-function))
	   (add-item (key item) (funcall #'add-item
				 :emit-function emit-function
				 :item item
				 :escape-string T
				 :key key))
	   (indent () (dotimes (i indentation-spaces) (funcall emit-function #\Space)))
	   (newline () (funcall emit-function #\Newline)))
      (indent)
      (start-block "image")
      (add-item ":path" absolute-path-spec)
      (end-block)
      (newline))))

(defun start-block (emit-function block-name)
    (flet ((emit (item) (funcall emit-function item)))
      (emit "(")
      (emit block-name)))

(defun end-block (emit-function)
    (flet ((emit (item) (funcall emit-function item)))
      (emit ")")))

(defun add-item (&key emit-function item escape-string key)
  (if escape-string
      (if key
	  (add-item-escape-string emit-function item key)
	  (add-item-escape-string emit-function item))
      (if key
	  (add-item-no-escape-string emit-function item key)
	  (add-item-no-escape-string emit-function item))))
      
      
(defun add-item-escape-string (emit-function item &optional (key nil))
  (flet ((emit (item) (funcall emit-function item))
    	 (space () (funcall emit-function #\Space)))
    (space)
    (when key
      (emit key)
      (space))
    (emit (prin1-to-string item))))

(defun add-item-no-escape-string (emit-function item &optional (key nil))
  (flet ((emit (item) (funcall emit-function item))
	 (space () (funcall emit-function #\Space)))
    (space)
    (when key
      (emit key)
      (space))
    (emit item)))

(defun add-item (emit-function item &optional (key nil) )
  (if key
   (add-item-escape-string emit-function item key)
   (add-item-escape-string emit-function item)))


(defun test-csv ()
  (with-open-file (csv-file "exampledata/small-table.csv")
    (compile-csv csv-file #'emit 1 2 T)))


(defun test-image ()
  (compile-image "exampledata/images/first-image.jpg" #'emit 1 2))



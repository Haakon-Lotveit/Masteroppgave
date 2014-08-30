;;; Front end compiler for the project
;;; Currently everything here is a sketch, and nothing is final.
;;; Everything that works is being moved over to compilation-unit-classes.lisp for Object Orientation

;;; There are four main things that have to be defined here:
;;;  - How to insert text (plain, markdown, unescaped(, others?))
;;;  - How to insert tables (two dimensional ones, from CSV only) (kind of done)
;;;  - How to insert images (kind of done)
;;;  - How to run an external program
;;;  - How to define things in the preludium is not in this sprint at all.

;;; In addition to this, an abstraction facility must be made available to let
;;; the users create their own rules that extend on the above four things.

(defun load-settings (settings-file)
  (null settings-file)
  (error "load-settings is not implemented"))

;; Disse tre skal over til compilation-unit-classes, selv om de er en stygg hack.
(defvar *indentation-level* 0)
(defvar *spaces-per-indent* 4)
  
(defun indentation-spaces ()
  (* *indentation-level* *spaces-per-indent*))

;; skal beholdes som en standard-formatterer, evt. en lambda som produserer denne funksjonen.
(defun std-emit (item)
  (format 'T "~A" item))

;; TODO: Disse skal gjøres om til metoder
;; (defun start-block (emit-function block-name)
;;     (flet ((emit (item) (funcall emit-function item)))
;;       (emit "(")
;;       (emit block-name)))

;; (defun end-block (emit-function)
;;     (flet ((emit (item) (funcall emit-function item)))
;;       (emit ")")))

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

(defun add-item (&key emit-function item escape-string key)
  (if escape-string
      (if key
	  (add-item-escape-string emit-function item key)
	  (add-item-escape-string emit-function item))
      (if key
	  (add-item-no-escape-string emit-function item key)
	  (add-item-no-escape-string emit-function item))))




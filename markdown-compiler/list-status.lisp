;; Hjelpeklasse
(defclass list-status ()
  ((in-list
    :accessor in-list
    :initform nil
    :initarg :in-list)
   (indentation-spaces
    :accessor indentation-spaces
    :initform '(0)
    :initarg :indentation-spaces)))

(defgeneric increase-indentation (status number))
(defmethod increase-indentation ((status list-status) number)
  (setf (indentation-spaces status)
	(+ (indentation-spaces status) number))
  status)

(defgeneric push-list-indent-level (status new-level))
(defmethod push-list-indent-level ((status list-status) new-level)
  (setf (indentation-spaces status)
	(cons new-level (indentation-spaces status)))
  status)

(defgeneric pop-list-indent-level (status))
(defmethod pop-list-indent-level ((status list-status))
  (pop (indentation-spaces status)))

(defgeneric currently-indented-spaces (status))
(defmethod currently-indented-spaces ((status list-status))
  (first (indentation-spaces status)))

(defmethod print-object ((status list-status) stream)
  (format stream "#<status-list in-list: ~A indentation-spaces: ~A>" (in-list status) (indentation-spaces status)))


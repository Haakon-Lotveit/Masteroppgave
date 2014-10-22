(defclass start-document (compilation-package)
  ((name :initform "start-of-document")
   (field-names :initform '())))

(defmethod compile-package ((package start-document))
  (newline-and-indent package)
  (start-block package "dokument"))


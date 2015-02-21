(defclass dokument-compilation-package (compilation-package)
  ((name :initform "dokument")))

(defmethod compile-package ((package dokument-compilation-package))
  (newline-and-indent package)
  (start-block package (name package))
  package)

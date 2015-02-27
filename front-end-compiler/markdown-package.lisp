(defclass markdown-package (text-compilation-package)
  ((name
    :initform "markdown")
   (text-type
    :initform "markdown-standard")
   (field-names
    :initform '("input-text"))))


(defmethod compile-package ((package markdown-package))
  (newline-and-indent package)
  (start-block package "formatted-text :version 0.1")
  (newline-and-indent package)
  (output package (prin1-to-string (compile-markdown-string (get-text package))))
  (end-block package))

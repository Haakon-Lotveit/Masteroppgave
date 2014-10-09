(defclass markdown-text-package (text-compilation-package)
  ((name
    :initform "markdown-text")
   (text-type
    :initform "markdown")
   (field-names
    :initform '("input-text"))))

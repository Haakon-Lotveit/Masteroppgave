(defclass markdown-package (text-compilation-package)
  ((name
    :initform "markdown")
   (text-type
    :initform "markdown-standard")))

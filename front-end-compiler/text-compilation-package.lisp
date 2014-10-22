(defclass text-compilation-package (compilation-package)
  ((name :initform (error "text-compilation-package has not overridden the name-field"))
   (text-type
    :reader text-type
    :initform (error "No text-type given to constructor. This should be set by overriding class")
    :initarg :text-type)))

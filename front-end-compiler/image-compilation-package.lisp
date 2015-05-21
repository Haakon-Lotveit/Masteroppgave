(defclass image-compilation-package (compilation-package)
  ((name :initform "IMAGE")
   (field-names :initform '("fil" "plassering" "størrelse"))))

(defmethod compile-package ((package image-compilation-package))
  (newline-and-indent package)
  (start-block package (name package))
  (output package (format nil " :FILE \"~A\" " (gethash "fil" (fields package))))
  (end-block package))



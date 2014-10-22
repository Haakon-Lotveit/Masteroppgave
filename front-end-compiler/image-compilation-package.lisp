(defclass image-compilation-package (compilation-package)
  ((name :initform "bilde")
   (field-names :initform '("fil" "plassering" "størrelse"))))

(defmethod compile-package ((package image-compilation-package))
  (newline-and-indent package)
  (start-block package (name package))
  (loop for key being the hash-keys of (fields package) do
       (add-property package key))
  (end-block package))


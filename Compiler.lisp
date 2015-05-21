;; This is intuitively equivalent to a Java interface plus some more bits:

;; We have defined a base-class called compiler, which has been given a constructor that can take arguments.
;; You give arguments by using the key given by initarg.
;; Default values have also been supplied. While CL supports a rich system of exception throwings,
;; this project has stuck to using simple errors instead.
;; If you do not supply an argument then the initform is used.
;; This causes an exception to be thrown.
;; We have also specified a simmple generic function. Generic functions are similar to interfaces for methods.
;; This generic function has a method that binds to the base class, throwing exceptions if you use a compiler that doesn't override it.
;; This is similar to throwing the OperationNotSupportedException in Java (which is a RuntimeException).

(defclass compiler () ((name :reader get-name 
			     :initarg :name 
			     :initform (error "You must specify a name for any compiler"))
		       (version :reader get-version 
				:initarg :version 
				:initform (error "You must specify a version for your compiler"))
		       ))

(defclass generic-compiler (compiler)
  ((compilation-function :reader get-compilation-function
			 :initarg :compilation-function
			 :initform (error "You must specify a compilation function for generic compilers"))))

(defgeneric backend-compile (compiler infile outfile)
  (:documentation "Compiles a file found by filespec with the given compiler"))

(defmethod backend-compile ((compiler generic-compiler) infile outfile)
  (funcall (get-compilation-function compiler) infile outfile))

(defmethod backend-compile ((compiler compiler) infile outfile)
  (error "Base method for compilation is called. You must override the method of your compiler"))

(defmethod print-object ((object compiler) stream)
  (format stream "#<AuRa Backend Compiler \"~A\" ver: ~A>"
	  (get-name object)
	  (get-version object)))

;; A (very simple) system for registering backend-compilers into the system. 
(defvar *compilers* (make-hash-table :test 'equal)) ;; This should be a class-slot

(defgeneric provide-compiler (compiler)
  (:documentation "Registers a back-end compiler in the system"))

(defmethod provide-compiler ((compiler compiler))
  (let ((name (get-name compiler)))
    (setf (gethash name *compilers*) compiler)))

(defun get-backend-compiler (compiler-name)
  (gethash compiler-name *compilers*))

(defun list-backend-compilers ()
  (let ((compilers ()))
    (loop for compiler-name being the hash-keys of *compilers* do
	 (push compiler-name compilers))
    compilers))

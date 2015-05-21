(defun glue-compile-stuff (&key ((:infile infile)) ((:outfile outfile)) ((:compiler-name compiler-name)))
  (let ((compiler (get-backend-compiler compiler-name))
	(betweenfile "temporary.mfo"))
    (unless compiler
      (error "Compiler found not found"))
    (when (probe-file betweenfile)
      (delete-file (probe-file betweenfile)))
    (fec-compile-file infile betweenfile)
    (when (probe-file outfile)
      (delete-file (probe-file outfile)))
    (backend-compile compiler betweenfile outfile)))


(defun glue-compile-stuff-from-hash-table (hash-table)
  (let ((infile        (gethash "input-file" hash-table))
	(outfile       (gethash "output-file" hash-table))
	(compiler-name (gethash "compiler" hash-table)))
    (format 'T "Supposed to compile with following:~% :infile ~A~% :outfile ~A~% :compiler-name ~A~%But I won't...~%"
	    infile
	    outfile
	    compiler-name)))

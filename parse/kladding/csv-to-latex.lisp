#| This is a simple test to see how I can generate tables from CSV. |#

;; This is a filthy dirty hack to load some libs.
;; I'm not going to bother to do it right in a sketching
;; environment. ^_^
(ql:quickload "cl-csv")

;; The actual function
;; Note that we do inversion of control here, meaning that it will write to whatever
;; you tell it to write to. table-spec is taken straight outta compton/LaTeX.
;; It's an easy format to understand so I'm not worried.
;; So far you do not get any styling from it, but that's for a later day.
;; TODO: Allow specifying if the first row is headers
;; TODO: Allow specifying separate headers
;; TODO: Allow lines between rows.
;; TODO: It should read from a stream, not necessarily a file
(defun get-file (file table-spec output-stream)
  (let ((csv-data (with-open-file (csv-file file :direction :input)
		    (cl-csv:read-csv csv-file :skip-first-p 'NIL))))
    (format output-stream "\\begin{tabular}{~A}~%\\hline~%" table-spec)
    (loop for row in csv-data do
	 (format output-stream "~{~A~^ & ~} \\\\ \\hline~%" row))
    (format output-stream "\\end{tabular} \\\\")))

(defun write-latex-file ()
  (with-open-file (out "/home/haakon/testing.tex"
		       :direction :output
		       :if-exists :supersede
		       :if-does-not-exist :create)
    (format out "\\documentclass[11pt]{article}~%")
    (format out "\\usepackage{cite}~%")
    (format out "\\usepackage{hyperref}~%")
    (format out "\\usepackage[T1]{fontenc}~%")
    (format out "\\usepackage[utf8]{inputenc}~%")
    (format out "~%")
    (format out "\\begin{document}~%")
    (format out "\\section{table}~%")
    (format out "~%")
    (get-file
     "/home/haakon/git/Masteroppgave/parse/kladding/apples-vs-oranges.csv"
     "| r | l | l |"
     out)
    (format out "~%")
    (format out "~%")
    (format out "\\end{document}~%")))


;; This is supposed to take a csv file and produce a table from it.
;; It should, but does not as of yet, produce some sort of table specification.
;; TODO: take a table specification
(defun table-from-csv (csv-file output-stream)
  (with-open-file (fs csv-file :direction :input)
    (format output-stream "(table ~%  ~{~S~^~%  ~})~%"
	    (cl-csv:read-csv fs :skip-first-p nil))))

(defun table-to-latex (table output-stream)
  (let ((line
	 (case (cadadr table)
	   (:single-line "\\hline")
	   (:no-line "")
	   (otherwise "\\hline"))))
    (format output-stream "\\begin{tabular}{~A}~%\\hline~%" (caadr table))

    (loop for row in (cddr table) do
	 (format output-stream "~{~A~^ & ~} \\\\ ~A~%" row line))
    (format output-stream "\\end{tabular}~%")))

(table-to-latex '(table ("| r | l | l |" :no-line) ("name" "price/kg (NOK)" "availability (kg)") ("Apples" "15" "420") ("Oranges" "20" "120"))
		*standard-output*)



(defun tst (line)
  (let ((foo (case (cadadr line)
	       (:sl "single line")
	       (:nl "")
	       (otherwise "single line"))))
    (print foo)
    foo))



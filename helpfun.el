(defun insert-iso-date ()
  (interactive)
  (let ((date (iso-date)))
    (insert date)
    date))

(defun iso-date ()
  (interactive)
  (format-time-string "%Y-%m-%d" (current-time)))


(defun hentet ()
  (interactive)
  (insert
   (format " | hentet %s"
	   (format-time-string "%Y-%m-%d"))))

(defun urlifier ()
  (interactive)
  (progn
    (move-beginning-of-line nil)
    (insert "@url{ ")
    (move-end-of-line 1)
    (just-one-space 0)
    (insert ",\n    howpublished = \"")
    (delete-char 1)
    (just-one-space 0)
    (move-end-of-line 1)
    (just-one-space 0)
    (insert "\",\n    title = \"")
    (delete-char 1)
    (just-one-space 0)
    (move-end-of-line 1)
    (just-one-space 0)
    (insert "\",\n    year = \"")
    (delete-char 1)
    (just-one-space 0)
    (move-end-of-line 1)
    (just-one-space 0)
    (insert (format "\",\n    note = \"[Online; accessed %s]\", }\n\n" (iso-date)))))



 

(defun hentet ()
  (interactive)
  (insert
   (format " | hentet %s"
	   (format-time-string "%Y-%m-%d"))))


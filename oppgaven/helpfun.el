(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(defun masteroppgave-add-cite-todo ()
  (interactive)
  (insert "[ADD-CITE]"))

(defalias 'ac 'masteroppgave-add-cite-todo)


;; Emacs configure from http://www.aaronbedra.com/emacs.d/
(require 'org-install)
(require 'ob-tangle)

(setenv "PATH" (concat "/usr/local/bin:/Users/ayang/.cabal/bin:" (getenv "PATH")))
(setq exec-path (append exec-path '("/usr/local/bin")))
(require 'cl)

(load "package")
(package-initialize)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

(setq package-archive-enable-alist '(("melpa" deft magit)))

(defvar ayang/packages '(ac-slime
                         auto-complete
                         autopair
                         deft
                         flycheck
                         ggtags
                         git-gutter
                         gist
                         go-mode
                         graphviz-dot-mode
                         haml-mode
                         haskell-mode
                         htmlize
                         jedi
                         magit
                         markdown-mode
                         marmalade
                         multiple-cursors
                         nodejs-repl
                         nrepl
                         o-blog
                         org
                         paredit
                         php-mode
                         projectile
                         python-mode
                         restclient
                         ruby-mode
                         rvm
                         smex
                         solarized-theme
                         undo-tree
                         w3m
                         web-mode
                         wrap-region
                         writegood-mode
                         yaml-mode
                         zenburn-theme)
  "Default packages")

(defun ayang/packages-installed-p ()
  (loop for pkg in ayang/packages
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

(unless (ayang/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg ayang/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))

;; Splash Screen
(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'org-mode)

;; Desktop
(require 'desktop)
(desktop-save-mode 1)
(defun my-desktop-save ()
  (interactive)
  ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
  (if (eq (desktop-owner) (emacs-pid))
      (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'my-desktop-save)

;; Scrollbar, tool bar, menu bar
(scroll-bar-mode -1)
(tool-bar-mode -1)
;; (menu-bar-mode -1)

;; Marking text
(delete-selection-mode t)
(transient-mark-mode t)
(setq x-select-enable-clipboard t)

;; Display text
(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b"))))

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

;; Indent
(setq-default c-basic-offset 4
              cperl-indent-level 4
              tab-width 4
              indent-tabs-mode t)

;; Backup files
(setq make-backup-files nil)

;; Short yes and no
(defalias 'yes-or-no-p 'y-or-n-p)

;; Insert newline like vim's o and O
(defun newline-below ()
  (interactive)
  (let ((oldpos (point)))
    (end-of-line)
    (newline-and-indent)))

(defun newline-above ()
  (interactive)
  (let ((oldpos (point)))
    (beginning-of-line)
    (newline-and-indent)
    (previous-line)))

(global-set-key (kbd "<C-return>") 'newline-below)
(global-set-key (kbd "<C-S-return>") 'newline-above)

;; Line number display
(setq prog-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook (lambda () (interactive) (setq show-trailing-whitespace 1)))

(defun comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

;; Key binding
(global-set-key (kbd "C-c w") 'whitespace-mode)
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-;") 'comment-or-uncomment-region-or-line)
(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-c C-k") 'compile)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-S-k") 'kill-whole-line)
(global-set-key (kbd "C-x c") 'desktop-change-dir)

(setq
 hippie-expand-try-functions-list
 '(try-expand-dabbrev ;; Try to expand word "dynamically", searching the current buffer.
   try-expand-dabbrev-all-buffers ;; Try to expand word "dynamically", searching all other buffers.
   try-expand-dabbrev-from-kill ;; Try to expand word "dynamically", searching the kill ring.
   try-complete-file-name-partially ;; Try to complete text as a file name, as many characters as unique.
   try-complete-file-name ;; Try to complete text as a file name.
   try-expand-all-abbrevs ;; Try to expand word before point according to all abbrev tables.
   try-expand-list ;; Try to complete the current line to an entire line in the buffer.
   try-expand-line ;; Try to complete the current line to an entire line in the buffer.
   try-complete-lisp-symbol-partially ;; Try to complete as an Emacs Lisp symbol, as many characters as unique.
   try-complete-lisp-symbol) ;; Try to complete word as an Emacs Lisp symbol.
 )
(setq-local hippie-expand-try-functions-list
            (cons 'ggtags-try-complete-tag hippie-expand-try-functions-list))

;; Misk
(setq echo-keystrokes 0.1
      use-dialog-box nil
      visible-bell t)
(show-paren-mode t)

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Vendor directory
(defvar ayang/vendor-dir (expand-file-name "vendor" user-emacs-directory))
(add-to-list 'load-path ayang/vendor-dir)

(dolist (project (directory-files ayang/vendor-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 Org Mode Settings                                                    ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-log-done t
      org-todo-keywords '((sequence "TODO" "INPROGRESS" "DONE"))
      org-todo-keyword-faces '(("INPROGRESS" . (:foreground "blue" :weight bold))))
(add-hook 'org-mode-hook
          (lambda ()
            (flyspell-mode)))
(add-hook 'org-mode-hook
          (lambda ()
            (writegood-mode)))

;; org-agenda
(global-set-key (kbd "C-c a") 'org-agenda)
(setq org-agenda-show-log t
      org-agenda-todo-ignore-scheduled t
      org-agenda-todo-ignore-deadlines t)
(setq org-agenda-files (list "~/Dropbox/Orgs/personal.org"
                             "~/Dropbox/Orgs/groupon.org"))

;; org-habit
(require 'org)
(require 'org-install)
(require 'org-habit)
(add-to-list 'org-modules "org-habit")
(setq org-habit-preceding-days 7
      org-habit-following-days 1
      org-habit-graph-column 80
      org-habit-show-habits-only-for-today t
      org-habit-show-all-today t)

;; org-babel
(require 'ob)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((sh . t)
   (ditaa . t)
   (plantuml . t)
   (dot . t)
   (ruby . t)
   (python . t)))

(add-to-list 'org-src-lang-modes (quote ("dot". graphviz-dot)))
(add-to-list 'org-src-lang-modes (quote ("plantuml" . fundamental)))
(add-to-list 'org-babel-tangle-lang-exts '("clojure" . "clj"))

(defvar org-babel-default-header-args:clojure
  '((:results . "silent") (:tangle . "yes")))

(defun org-babel-execute:clojure (body params)
  (lisp-eval-string body)
  "Done!")

(provide 'ob-clojure)

(setq org-src-fontify-natively t
      org-confirm-babel-evaluate nil)

(add-hook 'org-babel-after-execute-hook (lambda ()
                                          (condition-case nil
                                              (org-display-inline-images)
                                            (error nil)))
          'append)

;; org-abbrev
(add-hook 'org-mode-hook (lambda () (abbrev-mode 1)))

(define-skeleton skel-org-block-elisp
  "Insert an emacs-lisp block"
  ""
  "#+begin_src emacs-lisp\n"
  _ - \n
  "#+end_src\n")

(define-abbrev org-mode-abbrev-table "selisp" "" 'skel-org-block-elisp)

(define-skeleton skel-header-block
  "Creates my default header"
  ""
  "#+TITLE: " str "\n"
  "#+AUTHOR: Bruce Yang\n"
  "#+EMAIL: ayang23@gmail.com\n"
  "#+OPTIONS: toc:3 num:nil\n"
  "#+STYLE: <link rel=\"stylesheet\" type=\"text/css\" href=\"http://thomasf.github.io/solarized-css/solarized-light.min.css\" />\n")

(define-abbrev org-mode-abbrev-table "sheader" "" 'skel-header-block)

;; Utilities
;; deft
(setq deft-directory "~/Dropbox/deft")
(setq deft-use-filename-as-title t)
(setq deft-extension "org")
(setq deft-text-mode 'org-mode)

;; Smex
(setq smex-save-file (expand-file-name ".smex-items" user-emacs-directory))
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;; Ido
(ido-mode t)
(setq ido-enable-flex-matching t
      ido-use-virtual-buffers t)

(global-set-key (kbd "C-x C-b") 'ibuffer)

;; other settings
(setq column-number-mode t)

(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; autopair-mode
(require 'autopair)

;; ggtags
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))
;; (add-hook 'dired-mode-hook 'ggtags-mode)

;; multiple-cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-c C->") 'mc/unmark-next-like-this)
(global-set-key (kbd "C-c C-m") 'mc/mark-all-like-this)

;; git-gutter
(global-git-gutter-mode +1)

;; projectile
(projectile-global-mode)
(global-set-key (kbd "C-M-p") 'projectile-find-file)

;; wrapregion
(wrap-region-mode t)

;; undo-tree
(require 'undo-tree)
(global-undo-tree-mode)

;; Power lisp
(setq lisp-modes '(lisp-mode
                   emacs-lisp-mode
                   common-lisp-mode
                   scheme-mode
                   clojure-mode))

(defvar lisp-power-map (make-keymap))
(define-minor-mode lisp-power-mode "Fix keybindings; add power."
  :lighter " (power)"
  :keymap lisp-power-map
  (paredit-mode t))
(define-key lisp-power-map [delete] 'paredit-forward-delete)
(define-key lisp-power-map [backspace] 'paredit-backward-delete)

(defun ayang/engage-lisp-power ()
  (lisp-power-mode t))

(dolist (mode lisp-modes)
  (add-hook (intern (format "%s-hook" mode))
            #'ayang/engage-lisp-power))

(setq inferior-lisp-program "clisp")
(setq scheme-program-name "racket")

;; auto-complete
(require 'auto-complete-config)
(ac-config-default)

;; Indentation and buffer cleanup
(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun cleanup-region (beg end)
  "Remove tmux artifacts from region."
  (interactive "r")
  (dolist (re '("\\\\│\·*\n" "\W*│\·*"))
    (replace-regexp re "" nil beg end)))

(global-set-key (kbd "C-x M-t") 'cleanup-region)
(global-set-key (kbd "C-c n") 'cleanup-buffer)

(setq-default show-trailing-whitespace t)

;; flyspell
(setq flyspell-issue-welcome-flag nil)
(if (eq system-type 'darwin)
    (setq-default ispell-program-name "/usr/local/bin/aspell")
  (setq-default ispell-program-name "/usr/bin/aspell"))
(setq-default ispell-list-command "list")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Language hooks                                                                ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; web mode
(add-to-list 'auto-mode-alist '("\\.html" . web-mode))
(add-to-list 'auto-mode-alist '("\\.hbs$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb$" . web-mode))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 4)
  (setq web-mode-css-indent-offset 4)
  (setq web-mode-code-indent-offset 4)
  (setq web-mode-style-padding 0)
  (setq web-mode-script-padding 0)
  )
(add-hook 'web-mode-hook  'my-web-mode-hook)
;; python
;; jedi
(autoload 'jedi:setup "jedi" nil t)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:setup-keys t)
(setq jedi:complete-on-dot t)
(setq
 python-shell-interpreter "ipython"
 python-shell-interpreter-args ""
 python-shell-prompt-regexp "In \\[[0-9]+\\]: "
 python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
 python-shell-completion-setup-code
 "from IPython.core.completerlib import module_completion"
 python-shell-completion-module-string-code
 "';'.join(module_completion('''%s'''))\n"
 python-shell-completion-string-code
 "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

;; ruby
(add-hook 'ruby-mode-hook
          (lambda ()
            (autopair-mode)))

(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gemspec$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.ru$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile" . ruby-mode))

(rvm-use-default)

;; yaml
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))

;; coffescript
(defun coffee-custom ()
  "coffee-mode-hook"
  (make-local-variable 'tab-width)
  (set 'tab-width 2))

(add-hook 'coffee-mode-hook 'coffee-custom)

;; javascript
(defun js-custom ()
  "js-mode-hook"
  (setq js-indent-level 2))

(add-hook 'js-mode-hook 'js-custom)

;; markdown
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.mdown$" . markdown-mode))
(add-hook 'markdown-mode-hook
          (lambda ()
            (visual-line-mode t)
            (writegood-mode t)
            (flyspell-mode t)))
(setq markdown-command "pandoc --smart -f markdown -t html")
(setq markdown-css-path (expand-file-name "markdown.css" ayang/vendor-dir))

(if window-system
    (load-theme 'deeper-blue t)
  (load-theme 'wombat t))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

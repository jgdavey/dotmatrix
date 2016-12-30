;; Turn off useless UI elements -- do this as early as possible to
;; avoid visual thrashing.
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(setq inhibit-splash-screen t)
(setq inhibit-startup-screen t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message "")

;; Packages
(require 'package)
(require 'cl)

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(browse-kill-ring
                      cider
                      clj-refactor
                      company
                      exec-path-from-shell
                      expand-region
                      gist
                      magit
                      monokai-theme
                      multiple-cursors
                      org
                      paredit
                      zenburn-theme)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

(defmacro with-library (symbol &rest body)
  `(condition-case nil
       (progn
         (require ',symbol)
         ,@body)

     (error (message (format "I guess we don't have %s available." ',symbol))
            nil)))
(put 'with-library 'lisp-indent-function 1)

;; Editor

(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 4)            ;; but maintain correct appearance
(fset 'yes-or-no-p 'y-or-n-p)

;; Newline at end of file
(setq require-final-newline t)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; autosave the undo-tree history
(setq undo-tree-history-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq undo-tree-auto-save-history t)

(setq whitespace-style '(face trailing lines-tail tabs)
      whitespace-line-column 80)
(add-hook 'clojure-mode-hook 'whitespace-mode)

(load-theme 'zenburn t)

(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
(add-hook 'clojure-mode-hook          #'enable-paredit-mode)
(add-hook 'cider-repl-mode-hook       #'enable-paredit-mode)

(with-library magit
  (global-set-key (kbd "C-x g") 'magit-status)
  (magit-define-popup-switch 'magit-log-popup
    ?m "Omit merge commits" "--no-merges"))

(with-library cider
  (setq cider-prompt-for-symbol nil))

(with-library clj-refactor
  (defun my-clj-refactor-mode-hook ()
      (clj-refactor-mode 1)
      (cljr-add-keybindings-with-prefix "C-c C-m"))
  (add-hook 'clojure-mode-hook #'my-clj-refactor-mode-hook))

(with-library ido
  (setq ido-everywhere t
        ido-enable-flex-matching t)
  (ido-mode t)
  ;; Recent files support
  (require 'recentf)
  (recentf-mode t)
  (setq recentf-max-saved-items 50)
  (defun ido-recentf-open ()
    "Use `ido-completing-read' to \\[find-file] a recent file"
    (interactive)
    (if (find-file (ido-completing-read "Find recent file: " recentf-list))
      (message "Opening file...")
      (message "Aborting")))
  (global-set-key (kbd "C-x M-f") 'ido-recentf-open)
  (global-set-key (kbd "C-x C-M-f") 'ido-recentf-open))

(with-library paredit
  (define-key paredit-mode-map (kbd "M-)") 'paredit-forward-slurp-sexp))

(with-library uniquify
  (setq uniquify-buffer-name-style 'post-forward)
  (setq uniquify-separator ":"))

(with-library multiple-cursors
  (global-set-key (kbd "C-c C-l") 'mc/edit-lines)
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C->") 'mc/mark-all-like-this))

(let ((local "~/.emacs.d/default.el"))
  (if (file-exists-p local)
    (load-file local)
    nil))

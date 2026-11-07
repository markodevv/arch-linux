;; -*- lexical-binding: t; -*-
(require 'package)

(add-to-list 'package-archives '("melpa", "https://melpa.org/packages/") t)
(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(require 'jai-mode)
(load-theme 'dark t)

(setq use-package-always-ensure t)

(use-package evil
  :init
  (setq evil-want-keybinding nil
	evil-want-C-u-scroll t
	evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

;; Looks
(set-face-attribute 'default nil :family "Liberation Mono" :height 110)
(menu-bar-mode -1)    ; top menu
(tool-bar-mode -1)    ; icon toolbar
(scroll-bar-mode -1)  ; scrollbars
(set-frame-parameter nil 'alpha-background 70)
(add-to-list 'default-frame-alist '(alpha-background . 70))

;; Indentation
(setq-default indent-tabs-mode nil tab-width 2 c-basic-offset 2)
(setq-default js-indent-level 2)

;; Misc
(blink-cursor-mode -1)
(electric-pair-mode 1);
(setq make-backup-files nil)

(defun visual-trim (cmd)
  "Return a command that drops the last selected char (charwise only), then runs CMD."
  (lambda ()
    (interactive)
    (when (and (eq evil-visual-selection 'char) (> (point) (mark)))
      (goto-char (1- (point)))
      (evil-visual-refresh))
    (call-interactively cmd)))

;; Project/Compilation stuff

(defvar build-command "jai build.jai")
(defvar project-file-globs "*.jai")
(setq compilation-scroll-output t)

;; Mark vars as safe, to avoid anoying prompt when opening files
(put 'build-command 'safe-local-variable #'stringp)

(add-to-list 'display-buffer-alist
             '(is_quickfix-buffer
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.2)
               (window-parameters (no-delete-other-windows, t))))

(defun toggle-compilation ()
  (interactive)
  (let ((win (get-buffer-window "*compilation*")))
    (cond (win (delete-window win))
          ((get-buffer "*compilation*") (pop-to-buffer "*compilation*")))))

(defun is_quickfix-buffer (buf &optional _action)
  (with-current-buffer buf
    (derived-mode-p 'compilation-mode 'xref--xref-buffer-mode)))
(setq completion-styles '(substring partial-completion flex)
      completion-category-defaults nil
      completion-category-overrides nil)

(defun toggle-quickfix ()
  (interactive)
  (let ((win (seq-find (lambda (w) (is_quickfix-buffer (window-buffer w)))
                       (window-list))))
    (cond (win (delete-window win))
          ((buffer-live-p next-error-last-buffer)
           (display-buffer next-error-last-buffer))
          (t (message "No quickfix window")))))

(defun build-project ()
  (interactive)
  (let ((default-directory (if-let* ((p (project-current)))
                               (project-root p)
                             default-directory)))
    (compile build-command)))

(defun project-dir ()
  (if-let* ((p (project-current)))
      (project-root p)
    default-directory))

(defun project-grep (regexp)
  (interactive (list (read-string "Project grep:" nil nil)))
  (rgrep regexp (or project-file-globs "*") (project-dir)))

(defun project-find-file-globs ()
  (interactive)
  (let* ((root (project-root (project-current t)))
         (regexps (mapcar #'wildcard-to-regexp
                          (split-string (or project-file-globs "*"))))
         (files (seq-filter
                 (lambda (f)
                   (seq-some (lambda (re) (string-match-p re f)) regexps))
                 (project-files (project-current t))))
         (names (mapcar (lambda (f) (file-relative-name f root)) files))
         (choice (completing-read "Find file: " names nil t)))
    (find-file (expand-file-name choice root))))

;; Completion
(setq dabbrev-check-other-buffers t)

;; Keybinds
(evil-global-set-key 'normal (kbd "C-o") #'project-find-file-globs)
(evil-global-set-key 'normal (kbd "C-i") #'switch-to-buffer)
(evil-global-set-key 'normal (kbd "M-s") #'evil-write)
(evil-global-set-key 'normal (kbd "M-j") #'evil-scroll-down)
(evil-global-set-key 'normal (kbd "M-k") #'evil-scroll-up)
(evil-global-set-key 'normal (kbd "M-w") #'other-window)
(evil-global-set-key 'normal (kbd "`") #'toggle-quickfix)
(evil-global-set-key 'normal (kbd "R") #'evil-redo)
(evil-global-set-key 'normal "m" (lambda () (interactive) (evil-set-marker ?a)))
(evil-global-set-key 'normal "M" (lambda () (interactive) (evil-goto-mark ?a)))
(evil-global-set-key 'normal (kbd "<f7>") (lambda () (interactive) (find-file user-init-file)))
(evil-global-set-key 'normal (kbd "C-n") #'evil-switch-to-windows-last-buffer)
(evil-global-set-key 'normal (kbd "SPC d") #'dired-jump)
(evil-global-set-key 'insert (kbd "TAB") #'dabbrev-expand)
(evil-global-set-key 'normal (kbd "M-m") #'build-project)
(evil-global-set-key 'normal (kbd "M-e") #'next-error)
(evil-global-set-key 'normal (kbd "M-q") #'previous-error)
(evil-global-set-key 'normal (kbd "<f3>") #'project-grep)
(evil-global-set-key 'normal "p" #'evil-paste-before)
(evil-global-set-key 'normal "P" #'evil-paste-after)
(evil-global-set-key 'visual "y" (visual-trim #'evil-yank))
(evil-global-set-key 'visual "s" (lambda () (interactive) (evil-ex "'<,'>s/")))

(with-eval-after-load 'dired
  (evil-set-initial-state 'dired-normal 'normal)
  (evil-define-key 'normal dired-mode-map
    (kbd "RET") #'dired-find-file
    "f" #'find-file
    "R" #'dired-do-rename
    "d" #'dired-create-directory
    "D" #'dired-do-delete
    ))

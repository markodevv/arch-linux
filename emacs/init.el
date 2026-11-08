;; -*- lexical-binding: t; -*-
(package-initialize)

(require 'package)

(setq custom-file "~/.emacs.d/.emacs.custom.el")

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(setq use-package-always-ensure t)

(require 'jai-mode)
(require 'ido)
(load-theme 'dark t)

(use-package magit)
(use-package evil
  :init
  (setq evil-want-keybinding nil)
	(setq evil-undo-system 'undo-redo)
  (setq evil-want-integration t)
  :config
  (evil-mode 1))
(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init 'magit))
(use-package glsl-mode
  :mode ("\\.glsl\\'" "cs\\.sl\\'" "vs\\.sl\\'" "fs\\.sl\\'" "\\.slh\\'"))
(use-package rg :ensure t) 
(use-package zig-mode)

(setq dir-locals-file "project.el")

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
(ido-mode 1)
(setq make-backup-files nil)
(setq inhibit-splash-screen t)
(setq ring-bell-function 'ignore)
(setq vc-handled-backends nil)
(setq dabbrev-check-other-buffers t)
(setq scroll-conservatively 101)
(setq scroll-margin 3)

(if (eq system-type 'windows-nt)
    (progn
      (setq ls-lisp-dirs-first t)
      (setq ls-lisp-use-insert-directory-program nil)
      (setq dired-listing-switches "-alh"))
  (setq dired-listing-switches "-alh --group-directories-first"))

(defun visual-trim (cmd)
  "Return a command that drops the last selected char (charwise only), then runs CMD."
  (lambda ()
    (interactive)
    (when (and (eq evil-visual-selection 'char) (> (point) (mark)))
      (goto-char (1- (point)))
      (evil-visual-refresh))
    (call-interactively cmd)))

;; Project/Compilation stuff

; Config vars
(defvar project-name nil)
(defvar build-command "jai build.jai")
(defvar project-file-globs "*.jai")

;; Mark vars as safe, to avoid anoying prompt when opening files
(put 'project-name 'safe-local-variable #'stringp)
(put 'build-command 'safe-local-variable #'stringp)
(put 'project-file-globs 'safe-local-variable #'stringp)

(defvar projects-file (expand-file-name "my-projects.eld" user-emacs-directory))
(defvar projects nil)

(setq compilation-scroll-output t)
(setq completion-styles '(substring partial-completion flex)
      completion-category-defaults nil
      completion-category-overrides nil)


(add-to-list 'display-buffer-alist
             '(is-quickfix-buffer
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . bottom)
               (slot . 0)
               (window-height . 0.25)
               (window-parameters (no-delete-other-windows . t))))

(defun is-quickfix-buffer (buf &optional _action)
  (with-current-buffer buf
    (derived-mode-p 'compilation-mode 'xref--xref-buffer-mode)))

(defun toggle-quickfix ()
  (interactive)
  (let ((win (seq-find (lambda (w) (is-quickfix-buffer (window-buffer w)))
                       (window-list))))
    (cond (win (delete-window win))
          ((buffer-live-p next-error-last-buffer)
           (display-buffer next-error-last-buffer))
          (t (message "No quickfix window")))))

(defun save-projects-file()
  (with-temp-file projects-file
    (let ((print-length nil) (print-level nil))
      (prin1 projects (current-buffer)))))

(defun register-project ()
  (interactive)
  (when project-name
    (let ((root (project-dir)))
      (when root
        (unless (equal (cdr (assoc project-name projects)) root)
          (setf (alist-get project-name projects nil nil #'equal) root)
          (message "Registered project %s." project-name)
          (save-projects-file))))))

(defun load-project-list ()
  (when (file-exists-p projects-file)
    (setq projects
          (with-temp-buffer (insert-file-contents projects-file)
                            (read (current-buffer))))))

(defun start-screen-remove-project ()
  (interactive)
  (when-let* ((b (button-at (point)))
              (name (button-get b 'name)))
    (setq projects (assoc-delete-all name projects #'equal))
    (save-projects-file)
    (start-screen)))

(defun project-open (dir)
  (if (file-directory-p dir)
      (dired dir)
    (user-error "Project %s doesn't exist." dir)))

(define-derived-mode projects-buffer-mode special-mode "Start"
  "Start screen listing known projects.")

(defun start-screen ()
  (interactive)
  (let ((buf (get-buffer-create "*Projects*")))
    (with-current-buffer buf
      (projects-buffer-mode)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert "Projects\n\n")
        (if (null projects)
            (insert "No projects registered.\n")
          (dolist (p (sort (copy-sequence projects)
                           (lambda (a b) (string< (car a) (car b)))))
          (insert-text-button
           (format "%-25s %s" (car p) (cdr p))
           'name (car p)
           'dir (cdr p)
           'follow-link t
           'action (lambda (b) (project-open (button-get b 'dir))))
          (insert "\n"))))
    (switch-to-buffer buf)
    buf)))

(setq initial-buffer-choice #'start-screen)
(load-project-list)

;(save-projects-file)

(defun build-project ()
  (interactive)
  (let ((default-directory (project-dir)))
    (compile build-command)))

(defun project-dir ()
  (or (locate-dominating-file default-directory dir-locals-file)
      default-directory))

(defun project-grep (regexp)
  (interactive "sProject grep: ")
  (let ((default-directory (project-dir)))
    (compilation-start
     (format "rg -n --no-heading --color never -g \"{%s}\" -e %s ."
             (string-join (split-string project-file-globs) ",")
             (shell-quote-argument regexp))
     'grep-mode)))

(defun project-find-file-globs ()
  (interactive)
  (let* ((root (project-dir))
         (re (mapconcat #'wildcard-to-regexp
                        (split-string (or project-file-globs "*"))
                        "\\|"))
         (files (directory-files-recursively
                 root re nil
                 (lambda (dir) (not (string-match-p "/\\.git/?\\'" dir)))))
         (names (mapcar (lambda (f) (file-relative-name f root)) files)))
    (find-file (expand-file-name (completing-read "Find file: " names nil t) root))))

;; Magit stuff
(defun commit-with-message (msg)
  (interactive "sCommit message: ")
  (magit-run-git "commit" "-m" msg))

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
(evil-global-set-key 'normal (kbd "C-g C-g") #'magit-status)
(evil-global-set-key 'normal (kbd "C-f") #'evil-search-word-forward)

; Custom start screen
(evil-define-key 'normal projects-buffer-mode-map "R" #'start-screen-remove-project)
(evil-define-key 'normal projects-buffer-mode-map "g" #'start-screen)

; Magit
(with-eval-after-load 'magit
  (evil-define-key '(normal visual) magit-status-mode-map
    "s"         #'magit-stage
    "g"         #'magit-refresh
    "R"         #'magit-stash-clear
    "c"         #'commit-with-message
    "x"         #'magit-reset-quickly
    (kbd "M-w") #'other-window))

; Dired
(with-eval-after-load 'dired
  (evil-set-initial-state 'dired-normal 'normal)
  (evil-define-key 'normal dired-mode-map
    (kbd "RET") #'dired-find-file
    "f" #'find-file
    "g" #'revert-buffer
    "R" #'dired-do-rename
    "d" #'dired-create-directory
    "D" #'dired-do-delete
    ))

(load-file custom-file)

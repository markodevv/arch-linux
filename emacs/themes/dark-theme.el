;;; dark-theme.el --- Minimal dark theme -*- lexical-binding: t -*-

(deftheme dark "Plain dark theme.")

(let ((bg      "#0a0a0c")
      (fg      "#d1bb9f")
      (dim     "#707070")
      (comment "#71bd5e")
      (kw      "#b17bdd")
      (const   "#b17bdd")
      (str     "#e09572")
      (fn      "#f39a21")
      (type    "#f9d302")
      (warn    "#bf616a")
      (sel     "#2a2a3a"))

  (custom-theme-set-faces
   'dark
   `(default                  ((t (:background ,bg :foreground ,fg))))
   `(cursor                   ((t (:background ,fg))))
   `(region                   ((t (:background ,sel))))
   `(hl-line                  ((t (:background "#101010"))))
   `(fringe                   ((t (:background ,bg))))
   `(line-number              ((t (:foreground ,dim :background ,bg))))
   `(line-number-current-line ((t (:foreground ,fg :background ,bg))))
   `(mode-line                ((t (:background "#1a1a1a" :foreground ,fg :box nil))))
   `(mode-line-inactive       ((t (:background "#0a0a0a" :foreground ,dim :box nil))))
   `(minibuffer-prompt        ((t (:foreground ,kw :weight bold))))
   `(isearch                  ((t (:background ,fn :foreground ,bg))))
   `(lazy-highlight           ((t (:background "#3a3a3a"))))
   `(show-paren-match         ((t (:background "#3a3a3a" :weight bold))))

   ;; syntax
   `(font-lock-keyword-face       ((t (:foreground ,kw))))
   `(font-lock-type-face          ((t (:foreground ,type))))
   `(font-lock-string-face        ((t (:foreground ,str))))
   `(font-lock-constant-face      ((t (:foreground ,const))))
   `(font-lock-function-name-face ((t (:foreground ,fn))))
   `(font-lock-variable-name-face ((t (:foreground ,fg))))
   `(font-lock-comment-face       ((t (:foreground ,comment :slant italic))))
   `(font-lock-preprocessor-face  ((t (:foreground ,const))))
   `(font-lock-warning-face       ((t (:foreground ,warn))))
   `(error                        ((t (:foreground ,warn))))))

(provide-theme 'dark)
;;; dark-theme.el ends here

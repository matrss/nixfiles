;; Load use-package (at compile time? Not needed at runtime apparantly)
(eval-when-compile
  (require 'use-package))


;; Disable startup message.
(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message (user-login-name))

(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil)

;; Don't blink the cursor.
(setq blink-cursor-mode nil)

;; Accept 'y' and 'n' rather than 'yes' and 'no'.
(defalias 'yes-or-no-p 'y-or-n-p)

;; Stop creating backup and autosave files.
(setq make-backup-files nil
      auto-save-default nil)

;; Always show line and column number in the mode line.
(line-number-mode)
(column-number-mode)

;; Show line numbers at the left edge
(global-display-line-numbers-mode)

;; Trailing white space are banned!
(setq-default show-trailing-whitespace t)

(defun disable-trailing-whitespace ()
  (setq show-trailing-whitespace nil))

;; Shouldn't highlight trailing whitespaces in some modes.
(add-hook 'term-mode-hook #'disable-trailing-whitespace)
(add-hook 'eshell-mode-hook #'disable-trailing-whitespace)
(add-hook 'fundamental-mode-hook #'disable-trailing-whitespace)
; (add-hook 'term-mode #'disable-trailing-whitespace)
; (add-hook 'eshell-mode #'disable-trailing-whitespace)

;; I typically want to use UTF-8.
(prefer-coding-system 'utf-8)

;; Make moving cursor past bottom only scroll a single line rather
;; than half a page.
(setq scroll-step 1
      scroll-conservatively 5)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

(setq user-full-name "Matthias Riße")


(use-package base16-theme
  :config
  (load-theme 'base16-eighties t))

(use-package telephone-line
  :config
  (setq telephone-line-primary-left-separator 'telephone-line-flat)
  (setq telephone-line-secondary-left-separator 'telephone-line-flat)
  (setq telephone-line-primary-right-separator 'telephone-line-flat)
  (setq telephone-line-secondary-right-separator 'telephone-line-flat)
  (telephone-line-mode t))

(use-package which-key
  :init
  (setq which-key-idle-delay 0.5)
  :config
  (which-key-mode t))

(use-package undo-fu)

(use-package evil
  ;; evil-leader first, so that it works in initial buffers (*scratch*, ...)
  :after (undo-fu evil-leader)
  :init
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode t))

(use-package key-chord
  :after evil
  :config
  (key-chord-mode t)
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state)
  (key-chord-define evil-replace-state-map "jk" 'evil-normal-state))

(use-package evil-leader
  :config
  (global-evil-leader-mode t)
  (evil-leader/set-leader "<SPC>")
  (evil-leader/set-key
    "bk" 'kill-current-buffer
    "bb" 'ivy-switch-buffer))

(use-package ivy
  :config
  (ivy-mode t))

(use-package counsel
  :config
  (counsel-mode t))

(use-package swiper
  :after evil-leader
  :config
  ; (global-set-key "\C-s" 'swiper)
  (evil-leader/set-key "s" 'swiper))

(use-package company
  :config
  (global-company-mode t))

(use-package eglot)

(use-package direnv
  :config
  (direnv-mode t))

(use-package projectile
  :after evil-leader
  :init
  (setq projectile-project-search-path '("~/Projects/"))
  :config
  (projectile-mode t)
  (evil-leader/set-key "p" 'projectile-command-map))

(use-package ein)

(use-package direnv)

(use-package polymode)

(use-package magit)
(use-package evil-magit
  :after (evil magit))

(use-package org
  ; :hook (org-mode . org-indent-mode)
  :config
  (setq org-todo-keywords '((sequence "TODO" "BLOCKED" "DONE")))
  (setq org-adapt-indentation nil ; 'headline-data
	org-hide-leading-stars nil)
  (setq org-catch-invisible-edits 'show-and-error)
  (setq org-directory "~/Sync/org")
  (setq org-agenda-files '("~/Sync/org"))
  (setq org-default-notes-file (concat org-directory "/0-inbox.org")))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (evil-define-key 'normal 'evil-org-mode
    "go" 'org-open-at-point))
(use-package poly-org
  :after (polymode org))
  ; :hook (org-mode . poly-org-mode)

(use-package nix-mode)

(use-package markdown-mode)
(use-package evil-markdown
  :after (evil markdown-mode))
(use-package poly-markdown
  :after (polymode markdown-mode))
  ; :hook (markdown-mode . poly-markdown-mode)

(use-package dockerfile-mode)

(use-package docker-compose-mode)

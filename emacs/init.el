;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

;;; Packages

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

(use-package transient
  :demand t)

;;; Editing and appearance

(save-place-mode t)
(global-auto-revert-mode t)

(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

(setq frame-title-format
      '(:eval (if buffer-file-name
                  (expand-file-name buffer-file-name)
                (buffer-name))))
(context-menu-mode 1)

(when (display-graphic-p)
  (fringe-mode 0)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1))
(setq-default cursor-type 'bar)
(blink-cursor-mode 0)
(setq-default cursor-in-non-selected-windows nil)

(setq frame-resize-pixelwise t)

(fset 'yes-or-no-p 'y-or-n-p)
(setq make-backup-files nil)
(setq delete-by-moving-to-trash t
      create-lockfiles nil
      auto-save-default nil
      inhibit-startup-screen t
      ring-bell-function 'ignore)

(setq native-comp-async-report-warnings-errors 'silent)

(setq-default indent-tabs-mode nil)
(setq jit-lock-defer-time 0)
(when (and (display-graphic-p) (fboundp 'pixel-scroll-precision-mode))
  (pixel-scroll-precision-mode 1))
(setq redisplay-dont-pause t
      scroll-margin 3
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

(setq show-paren-delay 0.05)
(show-paren-mode 1)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :demand t
  :config
  (exec-path-from-shell-initialize))

(use-package all-the-icons
  :defer t)
(use-package all-the-icons-completion
  :after marginalia
  :config
  (all-the-icons-completion-marginalia-setup))

(setq custom-safe-themes t)

(use-package doom-themes
  :config
  (load-theme 'doom-gruvbox t)
  (set-face-attribute 'default nil :family "Iosevka" :height 200))

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(setq-default display-line-numbers-width 2)
(global-hl-line-mode t)

(use-package solaire-mode
  :config
  (solaire-global-mode 1))
(use-package goggles
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq-default goggles-pulse t))

;;; Mode line

(use-package doom-modeline
  :demand t
  :init
  (setq doom-modeline-modal-icon nil
        doom-modeline-unicode-fallback nil
        doom-modeline-window-width-limit nil
        doom-modeline-vcs-max-length 30
        doom-modeline-buffer-file-name-style 'file-name
        doom-modeline-percent-position nil
        doom-modeline-buffer-encoding nil
        doom-modeline-position-column-line-format '("%l:%c")
        vc-display-status t)
  (with-eval-after-load 'evil
    (setq evil-normal-state-tag " NORMAL "
          evil-insert-state-tag " INSERT "
          evil-visual-state-tag " VISUAL "
          evil-replace-state-tag " REPLACE "
          evil-motion-state-tag " MOTION "
          evil-operator-state-tag " OPERATOR "
          evil-emacs-state-tag " EMACS "))
  :config
  (line-number-mode 1)
  (column-number-mode 1)

  (defun my/doom-modeline-parent-folder (name)
    "Add the immediate parent folder to the cached filename label NAME."
    (if-let* ((file (buffer-file-name (buffer-base-buffer)))
              (directory (file-name-directory file)))
        (let ((prefix (concat (file-name-nondirectory
                               (directory-file-name directory)) "/")))
          (when (> (length name) 0)
            (add-text-properties 0 (length prefix)
                                 (text-properties-at 0 name) prefix))
          (add-face-text-property 0 (length prefix)
                                  'doom-modeline-buffer-path nil prefix)
          (concat prefix name))
      name))
  (advice-add 'doom-modeline-buffer-file-name :filter-return
              #'my/doom-modeline-parent-folder)

  (dolist (face '(doom-modeline-evil-normal-state
                  doom-modeline-evil-insert-state
                  doom-modeline-evil-visual-state
                  doom-modeline-evil-replace-state
                  doom-modeline-evil-motion-state
                  doom-modeline-evil-operator-state
                  doom-modeline-evil-emacs-state
                  doom-modeline-evil-user-state))
    (set-face-attribute face nil :box '(:line-width 1)
                        :inverse-video t :weight 'bold))
  (doom-modeline-mode 1))

;;; Keys and Evil

(setq mac-option-modifier 'meta)

(bind-key "s-/" 'comment-line)
(bind-key "C-q" 'kill-buffer-and-window)
(bind-key "M-d" 'dired-jump)

(bind-key "C-c C-p" 'popout)

(bind-key "C-c C-r" 'replace-string)
(bind-key "C-c C-e" 'count-words)
(bind-key* "C-c C-n" 'next-buffer)
(bind-key* "s-<left>" 'previous-buffer)
(bind-key "C-c C-f" 'xref-find-definitions)
(bind-key "C-c C-s" 'rgrep)
(bind-key "C-c C-c" 'projectile-find-other-file)
(bind-key "s-o" 'find-file)
(bind-key* "M-o" 'open-emacs-config)

(bind-key "`" "\\")

(defun open-kitty ()
  (interactive)
  (start-process "kitty" nil "kitty"))

(defun open-emacs-config ()
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(defun popout ()
  (interactive)
  (make-frame)
  (other-frame 1))

(use-package evil)
(evil-mode 1)

(dolist (p '((minibuffer-inactive-mode . emacs)
             (calendar-mode . emacs)
             (grep-mode . emacs)
             (Info-mode . emacs)
             (term-mode . emacs)
             (help-mode . emacs)
             (eshell-mode . emacs)
             (shell-mode . emacs)
             (vterm-mode . emacs)
             (dired-mode . emacs)
             (compilation-mode . emacs)
             (messages-buffer-mode . normal)))
  (evil-set-initial-state (car p) (cdr p)))

(define-key evil-normal-state-map (kbd "/") 'consult-line)
(define-key evil-normal-state-map (kbd "M-.") 'embark-dwim)
(define-key evil-normal-state-map (kbd "s-b") 'evil-switch-to-windows-last-buffer)

(setq evil-normal-state-cursor '(box "red")
      evil-insert-state-cursor '(bar "green"))

(use-package evil-leader)

(global-evil-leader-mode)

(evil-leader/set-leader "<SPC>")
(evil-leader/set-key
 ";" 'execute-extended-command
 ":" 'eval-expression
 "x" 'execute-extended-command
 "d" 'dired-jump
 "n" 'dirvish-side
 "b" 'ibuffer
 "e" 'dirvish-side
 "f" 'find-file
 "s" '(lambda ()
        (interactive)
        (split-window-horizontally)
        (switch-to-buffer "*scratch*")
        (balance-windows))
 "o" 'open-emacs-config
 "g" 'magit-status
 "p" 'evil-buffer
 "w" 'save-buffer
 "k" 'open-kitty
 "q" 'save-buffers-kill-emacs
 "cr" 'comment-or-uncomment-region)

(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

(setq help-window-select t)

;;; Completion and search

(use-package vertico
  :init
  (vertico-mode))

(use-package vertico-directory
  :straight nil
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package savehist
  :straight nil
  :init
  (savehist-mode))

(use-package emacs
  :straight nil
  :init
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (setq enable-recursive-minibuffers t))

(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (("M-A" . marginalia-cycle)
         :map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("M-." . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package igrep
  :commands (igrep igrep-find))

(use-package consult
  :bind (
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ("M-y" . consult-yank-pop)
         ("<help> a" . consult-apropos)
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s m" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))

  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init

  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  (advice-add #'register-preview :override #'consult-register-window)

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config

  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   :preview-key '(:debounce 0.4 any))

  (setq consult-narrow-key "<"))

;;; Languages and LSP

(use-package jinx
  :hook (org-mode . jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

(electric-pair-mode t)

(use-package markdown-mode
  :mode "\\.md\\'")
(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))
(use-package eglot
  :straight nil
  :commands (eglot eglot-ensure)
  :hook ((prog-mode html-mode mhtml-mode conf-toml-mode yaml-mode yaml-ts-mode)
         . my/eglot-ensure)
  :init
  (defun my/eglot-ensure ()
    "Start Eglot automatically for supported file buffers."
    (when buffer-file-name
      (require 'eglot)
      (when (eglot--lookup-mode major-mode)
        (eglot-ensure))))
  :config
  ;; Keep the existing Python server and add TOML support.
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("pylsp")))
  (add-to-list 'eglot-server-programs
               '((conf-toml-mode toml-ts-mode) . ("taplo" "lsp" "stdio"))))

(use-package company
  :commands company-mode
  :hook (eglot-managed-mode . my/eglot-company-mode)
  :init
  (defun my/eglot-company-mode ()
    "Enable completion while Eglot manages this buffer."
    (company-mode (if (eglot-managed-p) 1 -1)))
  (setq company-idle-delay 0.15
        company-minimum-prefix-length 2))

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package typescript-mode
  :mode "\\.tsx?\\'")

(use-package json-mode
  :mode "\\.json\\'")

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package bufler
  :bind* ("M-b" . bufler-switch-buffer))

(use-package which-key
  :config
  (which-key-mode))

;;; Files

(use-package all-the-icons-dired
  :defer t
  :init
  (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))

(use-package diredfl
  :hook
  ((dired-mode . diredfl-mode)
   (dirvish-directory-view-mode . diredfl-mode))
  :config
  (set-face-attribute 'diredfl-dir-name nil :bold t))

(use-package dirvish
  :init
  (dirvish-override-dired-mode)
  :custom
  (dirvish-bookmark-entries
   '(("H" "~/"                          "Home")
     ("d" "~/Downloads/"                "Downloads")
     ("m" "/Volumes/" "Drives")
     ("t" "~/.Trash/" "Trash")))
  (dirvish-header-line-format '(:left (path) :right (free-space)))
  :config
  (setq dirvish-preview-disabled-exts '("iso" "bin" "exe" "gpg" "elc" "eln"))
  (dirvish-peek-mode)
  (setq dired-dwim-target t)
  (setq dired-mouse-drag-files t)
  (setq mouse-drag-and-drop-region-cross-program t)

  :bind
  (("C-c f" . dirvish-fd)
   :map dirvish-mode-map
   ("h" . dired-up-directory)
   ("j" . dired-next-line)
   ("k" . dired-previous-line)
   ("l" . dired-find-file)
   ("." . dired-omit-mode)
   ("b"   . dirvish-bookmark-jump)
   ("f"   . dirvish-file-info-menu)
   ("y"   . dirvish-yank-menu)
   ("N"   . dirvish-narrow)
   ("^"   . dirvish-history-last)
   ("s"   . dirvish-quicksort)
   ("TAB" . dirvish-subtree-toggle)
   ("M-n" . dirvish-history-go-forward)
   ("M-p" . dirvish-history-go-backward)
   ("M-l" . dirvish-ls-switches-menu)
   ("M-m" . dirvish-mark-menu)
   ("M-f" . dirvish-toggle-fullscreen)
   ("M-s" . dirvish-setup-menu)
   ("M-e" . dirvish-emerge-menu)
   ("M-j" . dirvish-fd-jump)))

(when-let* ((gls (executable-find "gls")))
  (setq insert-directory-program gls))

;;; Projects and startup

(use-package magit
  :defer t)
(use-package projectile
  :demand t
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map))
  :config
  (projectile-mode 1))

(use-package recentf
  :straight nil
  :init
  (setq recentf-max-saved-items 100)
  (recentf-mode 1))

(use-package dashboard
  :demand t
  :init
  (setq dashboard-startup-banner 'official
        dashboard-projects-backend 'projectile
        dashboard-projects-switch-function #'projectile-switch-project-by-name
        dashboard-items '((recents . 8) (projects . 5) (bookmarks . 5)))
  :config
  (dashboard-setup-startup-hook))

;;; Compilation and utility buffers

(use-package smart-compile
  :commands smart-compile
  :config
  (add-to-list 'smart-compile-alist '("\\.js$" . "node %f")))
(use-package fancy-compilation
  :commands (fancy-compilation-mode))
(with-eval-after-load 'compile
  (fancy-compilation-mode))

(bind-key "s-<return>" 'recompile)

(setq compilation-ask-about-save nil)

(use-package leetcode
  :defer t)

(use-package vlf
  :defer t
  :init
  (require 'vlf-setup))

(use-package csv-mode
  :mode "\\.csv\\'")

(use-package popper
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1))

(when (display-graphic-p)
  (require 'color)
  (set-face-background 'line-number
                       (color-darken-name (face-attribute 'default :background) 2)))


(straight-use-package 'gptel)

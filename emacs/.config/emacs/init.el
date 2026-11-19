;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

;;; Package bootstrap

;; Detect edits saved in Emacs; check external edits explicitly with
;; `straight-check-all' rather than scanning package sources at startup.
(setq straight-check-for-modifications '(check-on-save find-when-checking))

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

;;; Core behavior

(save-place-mode 1)
(global-auto-revert-mode 1)
(context-menu-mode 1)
(electric-pair-mode 1)

(fset 'yes-or-no-p 'y-or-n-p)

(setq inhibit-startup-message t
      inhibit-startup-screen t
      initial-scratch-message nil
      make-backup-files nil
      delete-by-moving-to-trash t
      create-lockfiles nil
      auto-save-default nil
      ring-bell-function #'ignore
      native-comp-async-report-warnings-errors 'silent
      help-window-select t
      jit-lock-defer-time 0
      redisplay-dont-pause t
      scroll-margin 3
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

(setq-default indent-tabs-mode nil)

(when (and (display-graphic-p)
           (fboundp 'pixel-scroll-precision-mode))
  (pixel-scroll-precision-mode 1))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x))
  :demand t
  :config
  (exec-path-from-shell-initialize))

;;; Appearance

(setq frame-title-format
      '(:eval (if buffer-file-name
                  (expand-file-name buffer-file-name)
                (buffer-name)))
      custom-safe-themes t)

(setq-default cursor-type 'bar
              cursor-in-non-selected-windows nil
              display-line-numbers-width 2)

(blink-cursor-mode 0)
(global-hl-line-mode 1)
(show-paren-mode 1)
(setq show-paren-delay 0.05)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)

(use-package doom-themes
  :config
  (load-theme 'doom-gruvbox t)
  (when (display-graphic-p)
    (require 'color)
    (set-face-background
     'line-number
     (color-darken-name (face-attribute 'default :background) 2))))

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
                               (directory-file-name directory))
                              "/")))
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
    (set-face-attribute face nil
                        :box '(:line-width 1)
                        :inverse-video t
                        :weight 'bold))

  (doom-modeline-mode 1))

(use-package all-the-icons
  :defer t)

(use-package all-the-icons-completion
  :after marginalia
  :config
  (all-the-icons-completion-marginalia-setup))

(use-package solaire-mode
  :config
  (solaire-global-mode 1))

(use-package goggles
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq-default goggles-pulse t))

;;; Modal editing

(setq mac-option-modifier 'meta)

(use-package evil
  :demand t
  :bind (:map evil-normal-state-map
              ("/" . consult-line)
              ("M-." . embark-dwim)
              ("s-b" . evil-switch-to-windows-last-buffer)
              ([escape] . keyboard-quit)
              :map evil-visual-state-map
              ([escape] . keyboard-quit))
  :init
  (setq evil-normal-state-cursor '(box "red")
        evil-insert-state-cursor '(bar "green"))
  :config
  (evil-mode 1)
  (dolist (state '((minibuffer-inactive-mode . emacs)
                   (calendar-mode . emacs)
                   (grep-mode . emacs)
                   (Info-mode . emacs)
                   (term-mode . emacs)
                   (help-mode . emacs)
                   (eshell-mode . emacs)
                   (shell-mode . emacs)
                   (vterm-mode . emacs)
                   (dired-mode . emacs)
                   (dashboard-mode . emacs)
                   (welcome-dashboard-mode . normal)
                   (compilation-mode . emacs)
                   (messages-buffer-mode . normal)))
    (evil-set-initial-state (car state) (cdr state))))

(use-package evil-leader
  :after evil
  :demand t
  :config
  (global-evil-leader-mode 1)
  (evil-leader/set-leader "<SPC>")
  (let ((buffer-map (make-sparse-keymap))
        (code-map (make-sparse-keymap))
        (git-map (make-sparse-keymap))
        (open-map (make-sparse-keymap))
        (project-map (make-sparse-keymap))
        (search-map (make-sparse-keymap))
        (window-map (make-sparse-keymap)))
    (define-key buffer-map (kbd "b") #'consult-buffer)
    (define-key buffer-map (kbd "i") #'ibuffer)
    (define-key buffer-map (kbd "k") #'kill-current-buffer)
    (define-key buffer-map (kbd "n") #'next-buffer)
    (define-key buffer-map (kbd "p") #'previous-buffer)
    (define-key buffer-map (kbd "s") #'my/split-to-scratch)

    (define-key code-map (kbd "/") #'comment-or-uncomment-region)
    (define-key code-map (kbd "a") #'lsp-execute-code-action)
    (define-key code-map (kbd "c") #'compile)
    (define-key code-map (kbd "C") #'recompile)
    (define-key code-map (kbd "d") #'xref-find-definitions)
    (define-key code-map (kbd "D") #'xref-find-references)
    (define-key code-map (kbd "f") #'lsp-format-buffer)
    (define-key code-map (kbd "o") #'lsp-organize-imports)
    (define-key code-map (kbd "r") #'lsp-rename)
    (define-key code-map (kbd "w") #'delete-trailing-whitespace)
    (define-key code-map (kbd "x") #'consult-flymake)

    (define-key git-map (kbd "g") #'magit-status)

    (define-key open-map (kbd "d") #'dirvish-side)
    (define-key open-map (kbd "k") #'my/open-kitty)
    (define-key open-map (kbd "p") #'popper-toggle)
    (define-key open-map (kbd "P") #'popper-cycle)
    (define-key open-map (kbd "t") #'popper-toggle-type)

    (define-key project-map (kbd "b") #'projectile-switch-to-buffer)
    (define-key project-map (kbd "d") #'projectile-dired)
    (define-key project-map (kbd "f") #'projectile-find-file)
    (define-key project-map (kbd "p") #'projectile-switch-project)

    (define-key search-map (kbd "b") #'consult-line)
    (define-key search-map (kbd "f") #'consult-find)
    (define-key search-map (kbd "g") #'consult-git-grep)
    (define-key search-map (kbd "i") #'consult-imenu)
    (define-key search-map (kbd "r") #'consult-ripgrep)

    (define-key window-map (kbd "=") #'balance-windows)
    (define-key window-map (kbd "d") #'delete-window)
    (define-key window-map (kbd "h") #'evil-window-left)
    (define-key window-map (kbd "j") #'evil-window-down)
    (define-key window-map (kbd "k") #'evil-window-up)
    (define-key window-map (kbd "l") #'evil-window-right)
    (define-key window-map (kbd "o") #'delete-other-windows)
    (define-key window-map (kbd "s") #'evil-window-split)
    (define-key window-map (kbd "v") #'evil-window-vsplit)

    (define-key help-map (kbd "F") #'describe-face)
    (define-key help-map (kbd "'") #'describe-char)
    (define-key help-map (kbd "P") #'find-library)

    (evil-leader/set-key
     "SPC" #'projectile-find-file
     ";" #'execute-extended-command
     ":" #'eval-expression
     "~" #'popper-toggle
     "b" buffer-map
     "c" code-map
     "d" #'dired-jump
     "f" #'find-file
     "g" git-map
     "h" help-map
     "o" open-map
     "p" project-map
     "q" #'save-buffers-kill-emacs
     "s" search-map
     "w" window-map
     "x" #'my/split-to-scratch)

    (with-eval-after-load 'which-key
      (which-key-add-key-based-replacements
       "SPC b" "buffer"
       "SPC c" "code"
       "SPC g" "git"
       "SPC h" "help"
       "SPC o" "open"
       "SPC p" "project"
       "SPC s" "search"
       "SPC w" "window"))))

;;; Completion and search

(use-package vertico
  :init
  (vertico-mode 1))

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
  (savehist-mode 1))

(use-package emacs
  :straight nil
  :bind (("s-/" . comment-line)
         ("C-q" . kill-buffer-and-window)
         ("C-c C-p" . my/popout)
         ("C-c C-r" . replace-string)
         ("C-c C-e" . count-words)
         ("s-o" . find-file)
         ("`" . "\\")
         :map minibuffer-local-map
         ([escape] . my/minibuffer-keyboard-quit)
         :map minibuffer-local-ns-map
         ([escape] . my/minibuffer-keyboard-quit)
         :map minibuffer-local-completion-map
         ([escape] . my/minibuffer-keyboard-quit)
         :map minibuffer-local-must-match-map
         ([escape] . my/minibuffer-keyboard-quit)
         :map minibuffer-local-isearch-map
         ([escape] . my/minibuffer-keyboard-quit))
  :bind* (("C-c C-n" . next-buffer)
          ("s-<left>" . previous-buffer)
          ("M-o" . my/open-emacs-config))
  :init
  (defun my/crm-indicator (args)
    "Add a multiple-selection indicator to completion prompt ARGS."
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?\\]\\*\\|\\[.*?\\]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))

  (advice-add #'completing-read-multiple :filter-args #'my/crm-indicator)

  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt)
        enable-recursive-minibuffers t)

  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))

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
  (marginalia-mode 1))

(use-package embark
  :bind (("C-." . embark-act)
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
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package xref
  :straight nil
  :bind ("C-c C-f" . xref-find-definitions))

(use-package grep
  :straight nil
  :bind ("C-c C-s" . rgrep))

(use-package igrep
  :commands (igrep igrep-find))

(use-package consult
  :bind (("s-f" . consult-ripgrep)
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
        register-preview-function #'consult-register-format
        xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  (advice-add #'register-preview :override #'consult-register-window)
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

(use-package markdown-mode
  :mode "\\.md\\'")

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))

(use-package lsp-mode
  :commands (lsp
             lsp-deferred
             lsp-execute-code-action
             lsp-format-buffer
             lsp-organize-imports
             lsp-rename)
  :hook ((prog-mode html-mode mhtml-mode conf-toml-mode yaml-mode yaml-ts-mode)
         . lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-log-io nil
        lsp-idle-delay 0.3
        lsp-headerline-breadcrumb-enable nil
        lsp-warn-no-matched-clients nil
        lsp-file-watch-threshold nil
        ;; ty provides Python navigation and completion; Ruff adds linting and formatting.
        lsp-client-packages '(lsp-python-ty lsp-ruff lsp-rust lsp-clangd
                              lsp-javascript lsp-html lsp-css lsp-json
                              lsp-toml lsp-yaml)))

(use-package company
  :hook (lsp-completion-mode . company-mode)
  :init
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

;;; Files

(use-package dired
  :straight nil
  :bind (("M-d" . dired-jump)
         :map dired-mode-map
         ("<left>" . dired-up-directory)
         ("<right>" . dired-find-file)))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package diredfl
  :hook ((dired-mode . diredfl-mode)
         (dirvish-directory-view-mode . diredfl-mode))
  :config
  (set-face-attribute 'diredfl-dir-name nil :bold t))

(use-package dirvish
  :bind (("C-c f" . dirvish-fd)
         :map dirvish-mode-map
         ("h" . dired-up-directory)
         ("j" . dired-next-line)
         ("k" . dired-previous-line)
         ("l" . dired-find-file)
         ("." . dired-omit-mode)
         ("b" . dirvish-bookmark-jump)
         ("f" . dirvish-file-info-menu)
         ("y" . dirvish-yank-menu)
         ("N" . dirvish-narrow)
         ("^" . dirvish-history-last)
         ("s" . dirvish-quicksort)
         ("TAB" . dirvish-subtree-toggle)
         ("M-n" . dirvish-history-go-forward)
         ("M-p" . dirvish-history-go-backward)
         ("M-l" . dirvish-ls-switches-menu)
         ("M-m" . dirvish-mark-menu)
         ("M-f" . dirvish-toggle-fullscreen)
         ("M-s" . dirvish-setup-menu)
         ("M-e" . dirvish-emerge-menu)
         ("M-j" . dirvish-fd-jump))
  :init
  (dirvish-override-dired-mode)
  :custom
  (dirvish-bookmark-entries
   '(("H" "~/" "Home")
     ("d" "~/Downloads/" "Downloads")
     ("m" "/Volumes/" "Drives")
     ("t" "~/.Trash/" "Trash")))
  (dirvish-header-line-format '(:left (path) :right (free-space)))
  (dirvish-preview-disabled-exts '("iso" "bin" "exe" "gpg" "elc" "eln"))
  :config
  (dirvish-peek-mode 1)
  (setq dired-dwim-target t
        dired-mouse-drag-files t
        mouse-drag-and-drop-region-cross-program t))

(when-let* ((gls (executable-find "gls")))
  (setq insert-directory-program gls))

;;; Projects and startup

(use-package magit
  :defer t)

(use-package projectile
  :demand t
  :bind (("C-c C-c" . projectile-find-other-file)
         :map projectile-mode-map
         ("s-p" . projectile-command-map))
  :config
  (projectile-mode 1))

(use-package recentf
  :straight nil
  :init
  (setq recentf-max-saved-items 100)
  (recentf-mode 1))

(defvar old_dashboard nil
  "When non-nil, use the original dashboard instead of welcome-dashboard.
Set before loading this configuration, or change here and restart Emacs.")

(use-package dashboard
  :if old_dashboard
  :demand t
  :init
  (setq dashboard-startup-banner 'official
        dashboard-image-extra-props '(:height 200)
        dashboard-banner-logo-title nil
        dashboard-center-content t
        dashboard-projects-backend 'projectile
        dashboard-projects-switch-function #'projectile-switch-project-by-name
        dashboard-items '((recents . 8) (projects . 5)))
  :config
  (dashboard-setup-startup-hook))

(use-package welcome-dashboard
  :if (not old_dashboard)
  :straight (welcome-dashboard :type git :host github
                               :repo "konrad1977/welcome-dashboard"
                               :files ("welcome-dashboard.el"))
  :demand t
  :init
  (setq welcome-dashboard-use-nerd-icons t
        welcome-dashboard-max-number-of-recent-files 8
        welcome-dashboard-max-number-of-projects 5
        welcome-dashboard-max-number-of-todos 0)
  :config
  (defun my/welcome-dashboard-insert-banner (&rest _)
    "Insert the original Emacs image above the welcome dashboard."
    (let ((image-file (expand-file-name "assets/emacs.png" user-emacs-directory)))
      (when (and (display-graphic-p)
                 (image-type-available-p 'png)
                 (file-exists-p image-file))
        (with-current-buffer welcome-dashboard-buffer
          (let ((inhibit-read-only t)
                (image (create-image image-file 'png nil :height 200)))
            (save-excursion
              (goto-char (point-min))
              (insert (propertize " " 'display
                                  `(space :align-to (- center (0.5 . ,image)))))
              (insert-image image)
              (insert "\n\n")))))))
  (advice-add 'welcome-dashboard--refresh-screen :after
              #'my/welcome-dashboard-insert-banner)

  (defun my/welcome-dashboard-projectile-projects ()
    "Return Projectile projects for the welcome dashboard."
    (seq-take (projectile-relevant-known-projects)
              welcome-dashboard-max-number-of-projects))

  (defun my/welcome-dashboard-refresh-projects (&rest _)
    "Refresh dashboard projects from Projectile before rendering."
    (setq welcome-dashboard-recent-projects
          (my/welcome-dashboard-projectile-projects)))

  (defun my/welcome-dashboard-open-project (index)
    "Switch to the displayed Projectile project at INDEX."
    (when (<= 1 index (length welcome-dashboard-recent-projects))
      (projectile-switch-project-by-name
       (nth (1- index) welcome-dashboard-recent-projects))))

  (advice-add 'welcome-dashboard--get-recent-projects :override
              #'my/welcome-dashboard-projectile-projects)
  (advice-add 'welcome-dashboard--refresh-screen :before
              #'my/welcome-dashboard-refresh-projects)
  (advice-add 'welcome-dashboard--open-project-at-index :override
              #'my/welcome-dashboard-open-project)

  (dotimes (index 9)
    (let ((number (1+ index)))
      (define-key welcome-dashboard-mode-map (kbd (format "M-%d" number)) nil)
      (evil-define-key 'normal welcome-dashboard-mode-map (kbd (format "C-%d" number))
                  (lambda ()
                    (interactive)
                    (welcome-dashboard--open-project-at-index number)))
      (evil-define-key 'normal welcome-dashboard-mode-map (kbd (format "C-M-%d" number))
                  (lambda ()
                    (interactive)
                    (welcome-dashboard--open-recent-file-at-index number)))))

  (defun my/welcome-dashboard-shortcut-hints (args)
    "Match dashboard shortcut hints to the customized bindings."
    (pcase (plist-get args :shortcut-face)
      ('welcome-dashboard-recent-project-shortcut-face
       (setq args (plist-put args :shortcut-modifier "C-")))
      ('welcome-dashboard-recent-file-shortcut-face
       (setq args (plist-put args :shortcut-modifier "C-M-"))))
    args)
  (advice-add 'welcome-dashboard--insert-two-columns :filter-args
              #'my/welcome-dashboard-shortcut-hints)
  (welcome-dashboard-create-welcome-hook))

;;; Compilation and utility buffers

(use-package compile
  :straight nil
  :defer t
  :bind ("s-<return>" . recompile)
  :init
  (setq compilation-ask-about-save nil))

(use-package smart-compile
  :commands smart-compile
  :config
  (add-to-list 'smart-compile-alist '("\\.js$" . "node %f")))

(use-package fancy-compilation
  :after compile
  :config
  (fancy-compilation-mode 1))

(use-package leetcode
  :defer t)

(use-package vlf
  :defer t
  :init
  (require 'vlf-setup))

(use-package csv-mode
  :mode "\\.csv\\'")

(use-package popper
  :bind (("C-`" . popper-toggle)
         ("M-`" . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "\\*Warnings\\*"
          "\\*Backtrace\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          "\\*Shell Command Output\\*"
          "\\*Apropos\\*"
          "\\*Occur\\*"
          "\\*grep\\*"
          "\\*xref\\*"
          "\\*Flymake diagnostics.*\\*"
          "^\\*eshell.*\\*$"
          "^\\*shell.*\\*$"
          "^\\*term.*\\*$"
          "^\\*vterm.*\\*$"
          help-mode
          apropos-mode
          compilation-mode
          grep-mode
          occur-mode
          xref--xref-buffer-mode
          flymake-diagnostics-buffer-mode
          eshell-mode
          shell-mode
          term-mode
          vterm-mode)
        popper-display-control t
        popper-group-function #'popper-group-by-projectile)
  (popper-mode 1)
  (popper-echo-mode 1))

(use-package bufler
  :bind* ("M-b" . bufler-switch-buffer))

(use-package which-key
  :config
  (which-key-mode 1))

(use-package gptel
  :defer t)

;;; Helper commands

(defun my/open-kitty ()
  "Open a new Kitty terminal."
  (interactive)
  (start-process "kitty" nil "kitty"))

(defun my/open-emacs-config ()
  "Open this Emacs configuration."
  (interactive)
  (find-file (expand-file-name "init.el" user-emacs-directory)))

(defun my/popout ()
  "Open the current session in another frame."
  (interactive)
  (make-frame)
  (other-frame 1))

(defun my/split-to-scratch ()
  "Split the current window and show the scratch buffer."
  (interactive)
  (split-window-horizontally)
  (switch-to-buffer "*scratch*")
  (balance-windows))

(defun my/minibuffer-keyboard-quit ()
  "Abort a recursive edit, or deactivate an active region first."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark t)
    (when (get-buffer "*Completions*")
      (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))

;;; init.el ends here

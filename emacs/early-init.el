;;; early-init.el --- Frame and package startup -*- lexical-binding: t; -*-

;; straight.el handles packages before init.el configures them.
(setq package-enable-at-startup nil
      initial-frame-alist '((top . 60) (left . 50) (width . 85) (height . 60)))

;; Keep native macOS window decorations and the full-path title.
(add-to-list 'default-frame-alist '(undecorated . nil))
(add-to-list 'default-frame-alist '(font . "Iosevka-20"))

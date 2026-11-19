;;; early-init.el --- Frame and package startup -*- lexical-binding: t; -*-

;; Avoid frequent collections while loading packages, then restore normal GC.
(let ((normal-gc-cons-threshold gc-cons-threshold))
  (setq gc-cons-threshold (* 64 1024 1024))
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq gc-cons-threshold normal-gc-cons-threshold))))

;; Allow the window manager to size frames from the moment they open.
;; Keep their outer size when startup changes fonts or frame chrome.
(setq package-enable-at-startup nil
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

;; Keep native macOS window decorations and the full-path title.
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(left-fringe . 0))
(add-to-list 'default-frame-alist '(right-fringe . 0))
(add-to-list 'default-frame-alist '(undecorated . nil))
(add-to-list 'default-frame-alist '(font . "Iosevka-18"))

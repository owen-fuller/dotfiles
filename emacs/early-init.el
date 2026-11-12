;;; early-init.el --- Frame and package startup -*- lexical-binding: t; -*-

;; Allow the window manager to size frames from the moment they open.
;; Keep their outer size when startup changes fonts or frame chrome.
(setq package-enable-at-startup nil
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

;; Keep native macOS window decorations and the full-path title.
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(undecorated . nil))
(add-to-list 'default-frame-alist '(font . "Iosevka-20"))

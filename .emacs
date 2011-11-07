(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(gud-gdb-command-name "gdb --annotate=1")
 '(large-file-warning-threshold nil)
 '(safe-local-variable-values (quote ((erlang-indent-level . 2)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(setq erlang-indent-level 2)
(setq tab-width 2)
(setq indent-tabs-mode nil)

;;
;; Mac OS X fixes
;;
(setq default-input-method "MacOSX")
(setq mac-option-modifier nil
      mac-command-modifier 'meta
      x-select-enable-clipboard t)

;; Adding externally defined variables which may contain
;; sensitive information - sorry :)
(load "~/emacs/top-secret.el")

;;
;; Erlang mode
;;

(setq load-path (cons my-erlang-emacs-path
		       load-path))
(setq erlang-root-dir my-erlang-root-dir)
(setq exec-path (cons my-erlang-bin-dir exec-path))
(require 'erlang-start)
(add-hook 'erlang-mode-hook
             (lambda ()
            ;; when starting an Erlang shell in Emacs, the node name
            ;; by default should be "emacs"
            (setq inferior-erlang-machine-options '("-sname" "emacs"))
            ;; add Erlang functions to an imenu menu
            (imenu-add-to-menubar "imenu")))


;; Associate erlang-mode with YAWS files

(setq auto-mode-alist
      (cons '("\\.yaws$" . erlang-mode)
	    auto-mode-alist))

;; Extend erlang mode with Distel

(add-to-list 'load-path "~/git/distel/elisp")
(require 'distel)
(distel-setup)

;; Remove trailing whitespace on save
(add-hook 'before-save-hook
	  'delete-trailing-whitespace)

;; Flymake
;; - Has compatibility issues with distel, so... disabled.
;;(require 'erlang-flymake)

(defvar my-flymake-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\M-p" 'flymake-goto-prev-error)
    (define-key map "\M-n" 'flymake-goto-next-error)
    map)
  "Keymap for my flymake minor mode.")

(defun my-flymake-err-at (pos)
  (let ((overlays (overlays-at pos)))
    (remove nil
	    (mapcar (lambda (overlay)
		      (and (overlay-get overlay 'flymake-overlay)
			   (overlay-get overlay 'help-echo)))
		    overlays))))

(defun my-flymake-err-echo ()
  (message "%s" (mapconcat 'identity (my-flymake-err-at (point)) "\n")))

(defadvice flymake-goto-next-error (after display-message activate compile)
  (my-flymake-err-echo))

(defadvice flymake-goto-prev-error (after display-message activate compile)
  (my-flymake-err-echo))

(define-minor-mode my-flymake-minor-mode
  "Simple minor mode to navigate errors in flymake"
  nil
  nil
  :keymap my-flymake-minor-mode-map)

(add-hook 'erlang-mode-hook 'my-flymake-minor-mode)

;;; ERC

(require 'erc)
(erc-autojoin-mode t)
(setq erc-autojoin-channels-alist
      'my-erc-autojoin-list)
(erc-track-mode t)
(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
				"324" "329" "332" "353" "477"))
(setq erc-hide-list '("JOIN" "PART" "QUIT" "NICK"))

(defun djcb-erc-start-or-switch ()
  "Connect to ERC or switch to last active buffer"
  (interactive)
  (if (get-buffer 'my-erc-addr)
      (erc-track-switch-buffer 1)
    (when (y-or-n-p "Start ERC? ")
      (erc :server 'my-erc-server
           :port 6667
           :nick "joao"
           :full-name "joao.neves"))))

(global-set-key (kbd "C-c i") 'djcb-erc-start-or-switch)

;; color-theme
(add-to-list 'load-path "~/emacs/color-theme-6.6.0")
(require 'color-theme)
(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-hober)))
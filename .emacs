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

;; Associate erlang-mode with YAWS files

(setq auto-mode-alist 
      (cons '("\\.yaws$" . erlang-mode)
	    auto-mode-alist))

;; Extend erlang mode with Distel

(add-to-list 'load-path "~/git/distel/elisp")
(require 'distel)
(distel-setup)

;; Flymake

(require 'erlang-flymake)

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
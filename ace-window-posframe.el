;;; ace-window-posframe.el --- Use posframe to display keys. -*- lexical-binding: t -*-

(defvar aw--posframe-frames '())

(defvar aw-posframe-position-handler #'posframe-poshandler-window-center)

(defun aw--lead-overlay-posframe (path leaf)
  (let* ((wnd (cdr leaf))
         (str (format "%s" (apply #'string (reverse path))))
         ;; It's important that buffer names are not unique across
         ;; multiple invocations: posframe becomes very slow when
         ;; creating new frames, and so being able to reuse old ones
         ;; makes a huge difference. What defines "able to reuse" is
         ;; something like: a frame exists which hasn't been deleted
         ;; (with posframe-delete) and has the same configuration as
         ;; the requested new frame.
         (bufname (format "*aw-posframe-buffer-%s*" str)))
    (with-selected-window wnd
      ;; The number of frames won't be large, so it's fine to use
      ;; `add-to-list'.
      (add-to-list 'aw--posframe-frames bufname)
      (posframe-show bufname
                     :string str
                     :poshandler aw-posframe-position-handler
                     :font (face-font 'aw-leading-char-face)
                     :foreground-color (face-foreground 'aw-leading-char-face)
                     :background-color (face-background 'aw-leading-char-face)
                     :internal-border-width 1
                     :internal-border-color "gray"))))

(defun aw--remove-leading-chars-posframe ()
  ;; Hide rather than delete. See aw--lead-overlay-posframe for why.
  (mapc #'posframe-hide aw--posframe-frames))

(defun ace-window-posframe-enable ()
  (setq aw--lead-overlay-fn #'aw--lead-overlay-posframe
        aw--remove-leading-chars-fn #'aw--remove-leading-chars-posframe))

(defun ace-window-posframe-disable ()
  (setq aw--lead-overlay-fn #'aw--lead-overlay
        aw--remove-leading-chars-fn #'aw--remove-leading))

;;;###autoload
(define-minor-mode ace-window-posframe-mode
  ""
  :global t
  :require 'ace-window
  :init-value nil
  (cond ((not (display-graphic-p))
         (user-error "Only support be used with a graphic display"))
        (ace-window-posframe-mode (ace-window-posframe-enable))
        (t (ace-window-posframe-disable))))

(provide 'ace-window-posframe)

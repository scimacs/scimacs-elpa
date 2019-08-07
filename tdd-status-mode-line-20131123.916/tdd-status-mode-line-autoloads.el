;;; tdd-status-mode-line-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "tdd-status-mode-line" "tdd-status-mode-line.el"
;;;;;;  (22836 7187 0 0))
;;; Generated autoloads from tdd-status-mode-line.el

(autoload 'tdd-status/advance "tdd-status-mode-line" "\
Advance the TDD status further.

\(fn)" t nil)

(autoload 'tdd-status/back "tdd-status-mode-line" "\
Step back in the TDD status.

\(fn)" t nil)

(autoload 'tdd-status/clear "tdd-status-mode-line" "\
Clear the TDD status.

\(fn)" t nil)

(autoload 'tdd-status-minor-mode "tdd-status-mode-line" "\
Toggle the TDD status minor mode.

In this mode, the current TDD state will be displayed on the
mode-line, and the state is tracked on a per-buffer basis.
Switching between `tdd-status-global-mode' and
`tdd-status-minor-mode' is not supported.

\(fn &optional ARG)" t nil)

(defvar tdd-status-global-mode nil "\
Non-nil if Tdd-Status-Global mode is enabled.
See the `tdd-status-global-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `tdd-status-global-mode'.")

(custom-autoload 'tdd-status-global-mode "tdd-status-mode-line" nil)

(autoload 'tdd-status-global-mode "tdd-status-mode-line" "\
Toggle the global TDD status minor mode.

In this mode, the current TDD state will be displayed on the
mode-line, and the state is tracked globally. Switching between
`tdd-status-global-mode' and `tdd-status-minor-mode' is not
supported.

\(fn &optional ARG)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; tdd-status-mode-line-autoloads.el ends here

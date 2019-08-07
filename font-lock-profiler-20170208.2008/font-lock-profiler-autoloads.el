;;; font-lock-profiler-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "font-lock-profiler" "font-lock-profiler.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from font-lock-profiler.el

(autoload 'font-lock-profiler-region "font-lock-profiler" "\
Profile font-lock from BEG to END and present report.

\(fn BEG END)" t nil)

(autoload 'font-lock-profiler-buffer "font-lock-profiler" "\
Profile font-locking buffer and present report.

\(fn)" t nil)

(autoload 'font-lock-profiler-start "font-lock-profiler" "\
Start recording font-lock profiling information.

\(fn)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "font-lock-profiler" '("font-lock-profiler-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; font-lock-profiler-autoloads.el ends here

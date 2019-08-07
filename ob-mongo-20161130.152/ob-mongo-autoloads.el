;;; ob-mongo-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "ob-mongo" "ob-mongo.el" (22700 23551 0 0))
;;; Generated autoloads from ob-mongo.el

(autoload 'org-babel-execute:mongo "ob-mongo" "\
org-babel mongo hook.

\(fn BODY PARAMS)" nil nil)

(eval-after-load "org" '(add-to-list 'org-src-lang-modes '("mongo" . js)))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; ob-mongo-autoloads.el ends here

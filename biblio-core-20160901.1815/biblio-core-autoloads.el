;;; biblio-core-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "biblio-core" "biblio-core.el" (23522 17979
;;;;;;  0 0))
;;; Generated autoloads from biblio-core.el

(autoload 'biblio-lookup "biblio-core" "\
Perform a search using BACKEND, and QUERY.
Prompt for any missing or nil arguments.  BACKEND should be a
function obeying the interface described in the docstring of
`biblio-backends'.  Returns the buffer in which results will be
inserted.

\(fn &optional BACKEND QUERY)" t nil)

;;;***

;;;### (autoloads nil nil ("biblio-core-pkg.el") (23494 11181 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; biblio-core-autoloads.el ends here

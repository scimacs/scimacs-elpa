;;; org-ql-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "org-ql" "org-ql.el" (0 0 0 0))
;;; Generated autoloads from org-ql.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "org-ql" '("org-ql-")))

;;;***

;;;### (autoloads nil "org-ql-agenda" "org-ql-agenda.el" (0 0 0 0))
;;; Generated autoloads from org-ql-agenda.el

(autoload 'org-ql-search "org-ql-agenda" "\
Read QUERY and search with `org-ql'.
Interactively, prompt for these variables:

BUFFERS-FILES: A list of buffers and/or files to search.
Interactively, may also be:

- `buffer': search the current buffer
- `all': search all Org buffers
- `agenda': search buffers returned by the function `org-agenda-files'
- An expression which evaluates to a list of files/buffers
- A space-separated list of file or buffer names

GROUPS: An `org-super-agenda' group set.  See variable
`org-super-agenda-groups'.

NARROW: When non-nil, don't widen buffers before
searching. Interactively, with prefix, leave narrowed.

SORT: One or a list of `org-ql' sorting functions, like `date' or
`priority'.

\(fn BUFFERS-FILES QUERY &key NARROW GROUPS SORT)" t nil)

(function-put 'org-ql-search 'lisp-indent-function 'defun)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "org-ql-agenda" '("org-ql-")))

;;;***

;;;### (autoloads nil nil ("org-ql-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; org-ql-autoloads.el ends here

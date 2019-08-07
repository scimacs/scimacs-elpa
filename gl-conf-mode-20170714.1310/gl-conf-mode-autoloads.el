;;; gl-conf-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "gl-conf-mode" "gl-conf-mode.el" (23574 49754
;;;;;;  0 0))
;;; Generated autoloads from gl-conf-mode.el

(add-to-list 'auto-mode-alist '("gitolite.conf\\'" . gl-conf-mode))

(autoload 'gl-conf-mode "gl-conf-mode" "\
Major mode for editing gitolite config files.

Provides basic syntax highlighting (including detection of some
malformed constructs) and basic navigation.

\\{gl-conf-mode-map}

\(fn)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; gl-conf-mode-autoloads.el ends here

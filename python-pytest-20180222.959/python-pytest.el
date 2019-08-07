;;; python-pytest.el --- helpers to run pytest -*- lexical-binding: t; -*-

;; Author: wouter bolsterlee <wouter@bolsterl.ee>
;; Version: 0.2.1
;; Package-Version: 20180222.959
;; Package-Requires: ((emacs "24.4") (dash "2.12.0") (dash-functional "2.12.0") (magit-popup "2.12.0") (projectile "0.14.0") (s "1.12.0"))
;; Keywords: pytest, test, python, languages, processes, tools
;; URL: https://github.com/wbolster/emacs-python-pytest
;;
;; This file is not part of GNU Emacs.

;;; License:

;; 3-clause "new bsd"; see readme for details.

;;; Commentary:

;; This package provides helpers to run pytest.
;;
;; The main command is python-pytest-popup, which will show a
;; dispatcher menu, making it easy to change various options and
;; switches, and then run pytest using one of the actions, which can
;; also be run directly as commands:
;;
;; - python-pytest (run all tests)
;; - python-pytest-file (current file)
;; - python-pytest-file-dwim (‘do what i mean’ for current file)
;; - python-pytest-function (current function)
;; - python-pytest-function-dwim (‘do what i mean’ for current function)
;; - python-pytest-last-failed (rerun previous failures)
;; - python-pytest-repeat (repeat last invocation)
;;
;; A prefix argument causes the generated command line to be offered
;; for editing, and various customization options influence how some
;; of the commands work. See the README.rst for detailed information.

;;; Code:

(require 'comint)
(require 'python)

(require 'dash)
(require 'dash-functional)
(require 'magit-popup)
(require 'projectile)
(require 's)

(defgroup python-pytest nil
  "pytest integration"
  :group 'python
  :prefix "python-pytest-")

(defcustom python-pytest-confirm nil
  "Whether to edit the command in the minibuffer before execution.

By default, pytest will be executed without showing a minibuffer prompt.
This can be changed on a case by case basis by using a prefix argument
\(\\[universal-argument]\) when invoking a command.

When t, this toggles the behaviour of the prefix argument."
  :group 'pytest
  :type 'boolean)

(defcustom python-pytest-executable "pytest"
  "The name of the pytest executable."
  :group 'pytest
  :type 'string)

(defcustom python-pytest-setup-hook nil
  "Hooks to run before a pytest process starts."
  :group 'pytest
  :type 'hook)

(defcustom python-pytest-started-hook nil
  "Hooks to run after a pytest process starts."
  :group 'pytest
  :type 'hook)

(defcustom python-pytest-finished-hook nil
  "Hooks to run after a pytest process finishes."
  :group 'pytest
  :type 'hook)

(defcustom python-pytest-buffer-name "*pytest*"
  "Name of the pytest output buffer."
  :group 'pytest
  :type 'string)

(defcustom python-pytest-project-name-in-buffer-name t
  "Whether to include the project name in the buffer name.

This is useful when working on multiple projects simultaneously."
  :group 'pytest
  :type 'boolean)

(defcustom python-pytest-pdb-track t
  "Whether to automatically track output when pdb is spawned.

This results in automatically opening source files during debugging."
  :group 'pytest
  :type 'boolean)

(defcustom python-pytest-strict-test-name-matching nil
  "Whether to require a strict match for the ‘test this function’ heuristic.

This influences the ‘test this function’ behaviour when editing a
non-test function, e.g. ‘foo()’.

When nil (the default), the current function name will be used as
a pattern to run the corresponding tests, which will match
‘test_foo()’ as well as ‘test_foo_xyz()’.

When non-nil only ‘test_foo()’ will match, and nothing else."
  :group 'pytest
  :type 'boolean)

(defvar python-pytest--history nil
  "History for pytest invocations.")

(defvar python-pytest--project-last-command (make-hash-table :test 'equal)
  "Last executed command lines, per project.")

(defvar-local python-pytest--current-command nil
  "Current command; used in python-pytest-mode buffers.")

;;;###autoload (autoload 'python-pytest-popup "python-pytest" nil t)
(magit-define-popup python-pytest-popup
  "Show popup for running pytest."
  'python-pytest
  :switches
  '((?c "color" "--color" t)
    (?d "run doctests" "--doctest-modules")
    (?f "failed first" "--failed-first")
    (?l "show locals" "--showlocals")
    (?p "debug on error" "--pdb")
    (?q "quiet" "--quiet")
    (?s "do not capture output" "--capture=no")
    (?t "do not cut tracebacks" "--full-trace")
    (?v "verbose" "--verbose")
    (?x "exit after first failure" "--exitfirst"))
  :options
  '((?k "only names matching expression" "-k")
    (?m "only marks matching expression" "-m")
    (?t "traceback style" "--tb=" python-pytest--choose-traceback-style)
    (?x "exit after N failures or errors" "--maxfail="))
  :actions
  '("Run tests"
    (?t "Test all" python-pytest)
    (?x "Test last-failed" python-pytest-last-failed)
    "Run tests for current context"
    (?f "Test file" python-pytest-file-dwim)
    (?F "Test this file  " python-pytest-file)
    (?d "Test def/class" python-pytest-function-dwim)
    (?D "This def/class" python-pytest-function)
    "Repeat tests"
    (?r "Repeat last test run" python-pytest-repeat))
  :max-action-columns 2
  :default-action 'python-pytest-repeat)

;;;###autoload
(defun python-pytest (&optional args)
  "Run pytest with ARGS.

With a prefix argument, allow editing."
  (interactive (list (python-pytest-arguments)))
  (python-pytest--run
   :args args
   :edit current-prefix-arg))

;;;###autoload
(defun python-pytest-file (file &optional args)
  "Run pytest on FILE, using ARGS.

Additional ARGS are passed along to pytest.
With a prefix argument, allow editing."
  (interactive
   (list
    (buffer-file-name)
    (python-pytest-arguments)))
  (python-pytest--run
   :args args
   :file file
   :edit current-prefix-arg))

;;;###autoload
(defun python-pytest-file-dwim (file &optional args)
  "Run pytest on FILE, intelligently finding associated test modules.

When run interactively, this tries to work sensibly using
the current file.

Additional ARGS are passed along to pytest.
With a prefix argument, allow editing."
  (interactive
   (list
    (buffer-file-name)
    (python-pytest-arguments)))
  (python-pytest-file (python-pytest--sensible-test-file file) args))

;;;###autoload
(defun python-pytest-function (file func args)
  "Run pytest on FILE with FUNC (or class).

Additional ARGS are passed along to pytest.
With a prefix argument, allow editing."
  (interactive
   (list
    (buffer-file-name)
    (python-pytest--current-defun)
    (python-pytest-arguments)))
  (python-pytest--run
   :args args
   :file file
   :func func
   :edit current-prefix-arg))

;;;###autoload
(defun python-pytest-function-dwim (file func args)
  "Run pytest on FILE with FUNC (or class).

When run interactively, this tries to work sensibly using
the current file and function around point.

Additional ARGS are passed along to pytest.
With a prefix argument, allow editing."
  (interactive
   (list
    (buffer-file-name)
    (python-pytest--current-defun)
    (python-pytest-arguments)))
  (unless (python-pytest--test-file-p file)
    (setq
     file (python-pytest--sensible-test-file file)
     func (python-pytest--make-test-name func))
    (unless python-pytest-strict-test-name-matching
      (let ((k-option (-first (-partial #'s-prefix-p "-k") args)))
        (when k-option
          ;; try to use the existing ‘-k’ option in a sensible way
          (setq args (-remove-item k-option args)
                k-option (-as->
                          k-option s
                          (s-chop-prefix "-k" s)
                          (s-trim s)
                          (if (s-contains-p " " s) (format "(%s)" s) s))))
        (setq args (-snoc
                    args
                    (python-pytest--shell-quote file)
                    (if k-option
                        (format "-k %s and %s" func k-option)
                      (format "-k %s" func)))
              file nil
              func nil))))
  (python-pytest--run
   :args args
   :file file
   :func func
   :edit current-prefix-arg))

;;;###autoload
(defun python-pytest-last-failed (&optional args)
  "Run pytest, only executing previous test failures.

Additional ARGS are passed along to pytest.
With a prefix argument, allow editing."
  (interactive (list (python-pytest-arguments)))
  (python-pytest--run
   :args (-snoc args "--last-failed")
   :edit current-prefix-arg))

;;;###autoload
(defun python-pytest-repeat ()
  "Run pytest with the same argument as the most recent invocation.

With a prefix ARG, allow editing."
  (interactive)
  (let ((command (gethash
                  (python-pytest--project-root)
                  python-pytest--project-last-command)))
    (when python-pytest--current-command
      ;; existing python-pytest-mode buffer; reuse command
      (setq command python-pytest--current-command))
    (unless command
      (user-error "No previous pytest run for this project"))
    (python-pytest--run-command
     :command command
     :edit current-prefix-arg)))


;; internal helpers

(define-derived-mode python-pytest-mode
  comint-mode "pytest"
  "Major mode for pytest sessions (derived from comint-mode).")

(cl-defun python-pytest--run (&key args file func edit)
  "Run pytest for the given arguments."
  (setq args (python-pytest--transform-arguments args))
  (when (and file (file-name-absolute-p file))
    (setq file (python-pytest--relative-file-name file)))
  (when func
    (setq func (s-replace "." "::" func)))
  (let ((command)
        (thing (cond
                ((and file func) (format "%s::%s" file func))
                (file file))))
    (when thing
      (setq args (-snoc args (python-pytest--shell-quote thing))))
    (setq args (cons python-pytest-executable args)
          command (s-join " " args))
    (python-pytest--run-command
     :command command
     :edit edit)))

(cl-defun python-pytest--run-command (&key command edit)
  "Run a pytest command line."
  (let* ((default-directory (python-pytest--project-root)))
    (when python-pytest-confirm
      (setq edit (not edit)))
    (when edit
      (setq command
            (read-from-minibuffer
             "Command: "
             command nil nil 'python-pytest--history)))
    (add-to-history 'python-pytest--history command)
    (setq python-pytest--history (-uniq python-pytest--history))
    (puthash (python-pytest--project-root) command
             python-pytest--project-last-command)
    (python-pytest-run-as-comint command)))

(defun python-pytest-run-as-comint (command)
  "Run a pytest comint session for COMMAND."
  (let* ((buffer (python-pytest--get-buffer))
         (process (get-buffer-process buffer)))
    (with-current-buffer buffer
      (when (comint-check-proc buffer)
        (unless (or compilation-always-kill
                    (yes-or-no-p "Kill running pytest process?"))
          (user-error "Aborting; pytest still running")))
      (when process
        (delete-process process))
      (erase-buffer)
      (python-pytest-mode)
      (insert (format "cwd: %s\ncmd: %s\n\n" default-directory command))
      (setq python-pytest--current-command command)
      (when python-pytest-pdb-track
        (add-hook
         'comint-output-filter-functions
         'python-pdbtrack-comint-output-filter-function
         nil t))
      (run-hooks 'python-pytest-setup-hook)
      (make-comint-in-buffer "pytest" buffer "sh" nil "-c" command)
      (run-hooks 'python-pytest-started-hook)
      (setq process (get-buffer-process buffer))
      (set-process-sentinel process #'python-pytest--process-sentinel)
      (display-buffer buffer))))

(defun python-pytest--shell-quote (s)
  "Quote S for use in a shell command. Like `shell-quote-argument', but prettier."
  (if (s-equals-p s (shell-quote-argument s))
      s
    (format "'%s'" (s-replace "'" "'\"'\"'" s))))

(defun python-pytest--get-buffer ()
  "Get a create a suitable compilation buffer."
  (magit-with-pre-popup-buffer
    (if (eq major-mode 'python-pytest-mode)
        (current-buffer)  ;; re-use buffer
      (let ((name python-pytest-buffer-name))
        (when python-pytest-project-name-in-buffer-name
          (setq name (format "%s<%s>" name (python-pytest--project-name))))
        (get-buffer-create name)))))

(defun python-pytest--process-sentinel (proc _state)
  "Process sentinel helper to run hooks after PROC finishes."
  (with-current-buffer (process-buffer proc)
    (run-hooks 'python-pytest-finished-hook)))

(defun python-pytest--transform-arguments (args)
  "Transform ARGS so that pytest understands them."
  (-as->
   args args
   (python-pytest--switch-to-option args "--color" "--color=yes" "--color=no")
   (python-pytest--quote-string-option args "-k")
   (python-pytest--quote-string-option args "-m")))

(defun python-pytest--switch-to-option (args name on-replacement off-replacement)
  "Look in ARGS for switch NAME and turn it into option with a value.

When present ON-REPLACEMENT is substituted, else OFF-REPLACEMENT is appended."
  (if (-contains-p args name)
      (-replace name on-replacement args)
    (-snoc args off-replacement)))

(defun python-pytest--quote-string-option (args option)
  "Quote all values in ARGS with the prefix OPTION as shell strings."
  (--map-when
   (s-prefix-p option it)
   (s-concat option
             " "
             (-as-> it s
                    (substring s (length option))
                    (s-trim s)
                    (python-pytest--shell-quote s)))
   args))


(defun python-pytest--choose-traceback-style (prompt _value)
  "Helper to choose a pytest traceback style using PROMPT."
  (completing-read
   prompt '("long" "short" "line" "native" "no") nil t))


;; python helpers

(defun python-pytest--current-defun ()
  "Detect the current function/class (if any)."
  (save-excursion
    (let ((name (python-info-current-defun)))
      (unless name
        ;; jumping seems to make it work on empty lines.
        ;; todo: this could perhaps be improved.
        (python-nav-beginning-of-defun)
        (python-nav-forward-statement)
        (setq name (python-info-current-defun)))
      (unless name
        (user-error "No class/function found"))
      name)))

(defun python-pytest--make-test-name (func)
  "Turn function name FUNC into a name (hopefully) matching its test name.

Example: ‘MyABCThingy.__repr__’ becomes ‘test_my_abc_thingy_repr’."
  (-as->
   func s
   (s-replace "." "_" s)
   (s-snake-case s)
   (s-replace-regexp "_\+" "_" s)
   (s-chop-suffix "_" s)
   (s-chop-prefix "_" s)
   (format "test_%s" s)))


;; file/directory helpers

(defun python-pytest--project-name ()
  "Find the project name."
  (projectile-project-name))

(defun python-pytest--project-root ()
  "Find the project root directory."
  (projectile-project-root))

(defun python-pytest--relative-file-name (file)
  "Make FILE relative to the project root."
  ;; Note: setting default-directory gives different results
  ;; than providing a second argument to file-relative-name.
  (let ((default-directory (python-pytest--project-root)))
    (file-relative-name file)))

(defun python-pytest--test-file-p (file)
  "Tell whether FILE is a test file."
  (projectile-test-file-p file))

(defun python-pytest--find-test-file (file)
  "Find a test file associated to FILE, if any."
  (let ((test-file (projectile-find-matching-test file)))
    (unless test-file
      (user-error "No test file found"))
    test-file))

(defun python-pytest--sensible-test-file (file)
  "Return a sensible test file name for FILE."
  (if (python-pytest--test-file-p file)
      (python-pytest--relative-file-name file)
    (python-pytest--find-test-file file)))


;; third party integration

(with-eval-after-load 'direnv
  (defvar direnv-non-file-modes)
  (add-to-list 'direnv-non-file-modes 'python-pytest-mode))


(provide 'python-pytest)
;;; python-pytest.el ends here

This package offers an alternative to tabbing through links in
buffers, for instance, in an Info buffer.  `avy' is used to turn
opening a link from an O(N) operation into an O(1).

Use `ace-link-setup-default' to set up the default bindings, which currently
bind e.g. `ace-link-info' to "o", which was previously unbound and is
close to "l" (which by default goes back).

Supported modes: `Info-mode', `help-mode', `org-mode', `eww-mode',
`gnus-article-mode', `Custom-mode', `woman-mode', `goto-address-mode'.

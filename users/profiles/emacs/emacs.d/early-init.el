;; Disable some GUI distractions. We set these manually to avoid starting
;; the corresponding minor modes.
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . nil) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

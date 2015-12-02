;; package manager
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))

(package-initialize)

;; start server when init
(server-start)

;; auto installed package
(when (not package-archive-contents)
  (package-refresh-contents))

;; setting default package to be installed
(defvar my-default-packages
  '(undo-tree
    elpy
    evil
    evil-nerd-commenter
    evil-jumper
    evil-numbers
    xahk-mode
    markdown-mode
    sr-speedbar
    yasnippet
    auto-complete
    column-marker
    powerline
    powerline-evil
    flycheck
    flycheck-pyflakes
    highlight-symbol
    autopair
    git-commit-mode
    ecb
    tabbar
    color-theme
    magit
    column-marker
    evil-exchange
    evil-visualstar
    evil-jumper
    evil-matchit
    evil-search-highlight-persist
    evil-surround
    ))
(dolist (p my-default-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; elpy
(elpy-enable)
(elpy-use-ipython)

;; ecb
;; (require 'ecb)

;; magit
(setq-default magit-auto-revert-mode nil)
(setq-default magit-last-seen-setup-instructions "1.4.0")

;; color-theme
(require 'color-theme)
(color-theme-initialize)
(color-theme-robin-hood)

;; autopair
(require 'autopair)
(autopair-global-mode)
;; if you want to close autopair in some mode
;; (add-hook 'python-mode-hook #'(lambda ()
;;                                 (autopair-mode -1)))

;; flycheck
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

;; flycheck-pyflakes
(require 'flycheck-pyflakes)
(add-hook 'python-mode-hook 'flycheck-mode)

(add-to-list 'flycheck-disabled-checkers 'python-flake8)
(add-to-list 'flycheck-disabled-checkers 'python-pylint)

(require 'yasnippet)
(yas-global-mode 1)

(require 'auto-complete)
(ac-config-default)


;; markdown-mode
(autoload 'markdown-mode "markdown-mode"
         "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))

;; xahk-mode
(autoload 'xahk-mode "xahk-mode"
          "Major mode for editing AHK files" t)
(add-to-list 'auto-mode-alist '("\\.ahk\\'" . xahk-mode))

;; sr-speedbar
(require 'sr-speedbar)
(setq-default sr-speedbar-auto-refresh t)
(setq-default sr-speedbar-right-side nil)

;; powerline
(require 'powerline)
(require 'powerline-evil)
;; (powerline-center-evil-theme)
(defun my-powerline-evil-center-color-theme ()
  "Powerline's center-evil them with the evil state in color."
  (interactive)
  (setq-default mode-line-format
        '("%e"
          (:eval
           (let* ((active (powerline-selected-window-active))
                  (mode-line (if active 'mode-line 'mode-line-inactive))
                  (face1 (if active 'powerline-active1 'powerline-inactive1))
                  (face2 (if active 'powerline-active2 'powerline-inactive2))
                  (separator-left (intern (format "powerline-%s-%s"
                                                  powerline-default-separator
                                                  (car powerline-default-separator-dir))))
                  (separator-right (intern (format "powerline-%s-%s"
                                                   powerline-default-separator
                                                   (cdr powerline-default-separator-dir))))
                  (lhs (list (powerline-raw "%*" nil 'l)
                             (powerline-buffer-size nil 'l)
                             (powerline-buffer-id nil 'l)
                             (powerline-raw " ")
                             (funcall separator-left mode-line face1)
                             (powerline-narrow face1 'l)
                             (powerline-vc face1)))
                  (rhs (list (powerline-raw global-mode-string face1 'r)
                             (powerline-raw "%Z" face1 'r)
                             (funcall separator-right face1 mode-line)
                             (powerline-raw "%4l" face1 'r)
                             (powerline-raw ":" face1)
                             (powerline-raw "%3c" face1 'r)
                             (funcall separator-right face1 mode-line)
                             (powerline-raw " ")
                             (powerline-raw "%6p" nil 'r)
                             (powerline-hud face2 face1)))
                  (center (append (list (powerline-raw " " face1)
                                        (funcall separator-left face1 face2)
                                        (when (boundp 'erc-modified-channels-object)
                                          (powerline-raw erc-modified-channels-object face2 'l))
                                        (powerline-major-mode face2 'l)
                                        (powerline-process face2)
                                        (powerline-raw " " face2))
                                  (let ((evil-face (powerline-evil-face)))
                                    (if (split-string (format-mode-line minor-mode-alist))
                                        (append (if evil-mode
                                                    (list (funcall separator-right face2 evil-face)
                                                          (powerline-raw (powerline-evil-tag) evil-face 'l)
                                                          (powerline-raw " " evil-face)
                                                          (funcall separator-left evil-face face2)))
                                                (list (powerline-minor-modes face2 'l)
                                                      (powerline-raw " " face2)
                                                      (funcall separator-right face2 face1)))
                                      (list (powerline-raw (powerline-evil-tag) evil-face)
                                            (funcall separator-right evil-face face1)))))))
             (concat (powerline-render lhs)
                     (powerline-fill-center face1 (/ (powerline-width center) 2.0))
                     (powerline-render center)
                     (powerline-fill face1 (powerline-width rhs))
                     (powerline-render rhs)))))))

(my-powerline-evil-center-color-theme)

;; evil mode (vim simulator)
(require 'evil)
(evil-mode 1)

;; use emacs-symbols instead of words
(setq-default evil-symbol-word-search t)
;; the highlight result of searching will not timeout
(setq-default evil-flash-delay 99999)
;; If non nil then an inclusive visual character selection which
;; ends at the beginning or end of a line is turned into an
;; exclusive selection.
(setq-default evil-want-visual-char-semi-exclusive t)
;; Show error output of a shell command in the error buffer.
(setq-default evil-display-shell-error-in-message t)

(require 'evil-nerd-commenter)

(require 'evil-jumper)
(global-evil-jumper-mode)

(require 'evil-numbers)

;; only in evil's normal and visual state:
(define-key evil-normal-state-map "'+" 'evil-numbers/inc-at-pt)
(define-key evil-visual-state-map "'+" 'evil-numbers/inc-at-pt)

(define-key evil-normal-state-map "'-" 'evil-numbers/dec-at-pt)
(define-key evil-visual-state-map "'-" 'evil-numbers/dec-at-pt)

;; highlight-symbol
(require 'highlight-symbol)
(define-key evil-normal-state-map ",mm" 'highlight-symbol)
(define-key evil-normal-state-map ",mn" 'highlight-symbol-next)
(define-key evil-normal-state-map ",mp" 'highlight-symbol-prev)
(define-key evil-normal-state-map ",mc" 'highlight-symbol-remove-all)



;; evil keymaps
;; save file
(define-key evil-normal-state-map ",w" ":w")
;; show buffers
(define-key evil-normal-state-map ",b" ":ls")
;; show files in directory
(define-key evil-normal-state-map ",dd" "\C-xd")
;; only for windows
(define-key evil-normal-state-map ",s" ":eshell")
;; select all
(define-key evil-normal-state-map ",a" "ggVG")
;; edit .emacs file
(define-key evil-normal-state-map ",r" ":edit ~/.emacs")
;; toggle ECB mode
(define-key evil-normal-state-map ",o" 'sr-speedbar-toggle)
(define-key evil-normal-state-map ",O" 'ecb-activate)
;; make
(define-key evil-normal-state-map ",mk" ":compile")
(define-key evil-normal-state-map ",mr" ":recompile")

;; close current window
(define-key evil-normal-state-map ",q" ":q")
;; close other windows
(define-key evil-normal-state-map ",Q" "\C-x1")

;; remove white spaces at end of line
(define-key evil-normal-state-map "'rs" ":%s/[ \\t]+$//g")

;; format c-like source code
(add-hook 'c-mode-hook (lambda ()
          (define-key evil-normal-state-map "'f" ":%!astyle_c")))
(add-hook 'c++-mode-hook (lambda ()
          (define-key evil-normal-state-map "'f" ":%!astyle_c")))
(add-hook 'java-mode-hook (lambda ()
          (define-key evil-normal-state-map "'f" ":%!astyle_c")))
(add-hook 'js-mode-hook (lambda ()
          (define-key evil-normal-state-map "'f" ":%!astyle_c")))
;; format python source code
(add-hook 'python-mode-hook (lambda ()
            (define-key evil-normal-state-map "'f" ":%!recoding gbk | autopep8 -a - | recoding utf-8")))

;; format line
(define-key evil-normal-state-map "'F" "gqq")
(define-key evil-visual-state-map "'F" "gq")

;; align
(define-key evil-visual-state-map "'a" ":align")

;; comment source code
(define-key evil-normal-state-map "'ci" 'evilnc-comment-or-uncomment-lines)
(define-key evil-normal-state-map "'cc" 'evilnc-copy-and-comment-lines)
(define-key evil-visual-state-map "'ci" 'evilnc-comment-or-uncomment-lines)
(define-key evil-visual-state-map "'cc" 'evilnc-copy-and-comment-lines)

;; Setting English Font
(set-face-attribute
  'default nil :font "Consolas 11")

;; Chinese Font
(dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font)
                      charset
                      (font-spec :family "NSimSun" :size 16)))

;; 语言环境
(set-language-environment 'utf-8)
;; 新建文件的编码
(setq-default buffer-file-coding-system 'utf-8-unix)
;; 新建批处理文件的编码和换行符
(add-hook 'bat-mode-hook (lambda () (set-buffer-file-coding-system 'gbk-dos)))
;; 打开文件使用的, 优先级与声明的顺序相反
(prefer-coding-system 'utf-16le)
(prefer-coding-system 'chinese-gbk)
(prefer-coding-system 'utf-8)

(global-linum-mode t) ;show line number
(set-frame-width (selected-frame) 160)  ; window width
(set-frame-height (selected-frame) 45)  ; window height

;; indent
(setq-default default-tab-width 4)
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
(setq-default c-default-style "linux")
(setq-default c-basic-offset 4)

;; line spacing
(setq-default line-spacing 3)

;; disable bell
(setq-default visible-bell t)

;; remove emacs and gnus startup message
(setq-default inhibit-startup-message t)
(setq-default gnus-inhibit-startup-message t)

;; do not backup files
(setq-default make-backup-files nil)

;; paren match
(show-paren-mode t)

;; set title with buffer name
(setq-default frame-title-format "%b [%f] - emacs")

;; folding support
(add-hook 'python-mode-hook 'hs-minor-mode)
(add-hook 'c-mode-hook 'hs-minor-mode)
(add-hook 'c++-mode-hook 'hs-minor-mode)
(add-hook 'java-mode-hook 'hs-minor-mode)
(add-hook 'js-mode-hook 'hs-minor-mode)
(add-hook 'elisp-mode-hook 'hs-minor-mode)

;; disable copy/paste to system clipboard
(setq-default x-select-enable-clipboard nil)
(setq-default x-select-enable-primary nil)
(setq-default mouse-drag-copy-region nil)

;; copy and paste
(define-key evil-visual-state-map "'y" 'clipboard-kill-ring-save)
(define-key evil-visual-state-map "'p" "s\C-v")
(define-key evil-visual-state-map "'P" "s\C-v")
(define-key evil-normal-state-map "'y" "V'y")
(add-hook 'after-init-hook (lambda ()
    (define-key evil-insert-state-map "\C-v" 'clipboard-yank)
    (define-key evil-visual-state-map "\C-c" 'clipboard-kill-ring-save)
    (define-key evil-visual-state-map "\C-v" "s\C-v")
    ))
(define-key evil-normal-state-map "'P" 'clipboard-yank)
(define-key evil-normal-state-map "'p" "a\C-v")

;; next/previous make error
(add-hook 'compilation-mode-hook (lambda ()
                                   (define-key evil-normal-state-map ",cn" "\C-x`")
                                   (define-key evil-normal-state-map ",cp" "\M-gp")
                                   ))

;; for ECB mode return key
(define-key evil-motion-state-map (kbd "RET") nil)
(define-key evil-normal-state-map (kbd "RET") 'evil-ret)
(add-hook 'ecb-history-buffer-after-create-hook 'evil-motion-state)
(add-hook 'ecb-directories-buffer-after-create-hook 'evil-motion-state)
(add-hook 'ecb-methods-buffer-after-create-hook 'evil-motion-state)
(add-hook 'ecb-sources-buffer-after-create-hook 'evil-motion-state)

;; fill-column: width of a line
(setq-default fill-column 80)

;; highlight tags and trailing space
(require 'whitespace)
(setq whitespace-style '(face tabs trailing))
(global-whitespace-mode t)

;; highlight the 81 column
(require 'column-marker)
(add-hook 'c-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'c++-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'java-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'python-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'lua-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'perl-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'ruby-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'lisp-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'emacs-lisp-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'text-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'latex-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'markdown-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'org-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'php-mode-hook (lambda () (interactive) (column-marker-3 80)))
(add-hook 'css-mode-hook (lambda () (interactive) (column-marker-3 80)))

;; y/n to make answer
(defalias 'yes-or-no-p 'y-or-n-p)

;; exchange text
(require 'evil-exchange)
(setq evil-exchange-key (kbd "'x"))
(setq evil-exchange-cancel-key (kbd "'X"))
(evil-exchange-install)

;; visual star
(require 'evil-visualstar)
(global-evil-visualstar-mode t)

(require 'evil-jumper)
(global-evil-jumper-mode)

(require 'evil-matchit)
(global-evil-matchit-mode 1)

(require 'evil-search-highlight-persist)
(global-evil-search-highlight-persist t)

(require 'evil-surround)
(global-evil-surround-mode 1)

(modify-syntax-entry ?_ "w")

(setq-default gdb-many-windows t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ecb-compile-window-height 10)
 '(ecb-compile-window-width (quote edit-window))
 '(ecb-options-version "2.40")
 '(ecb-source-path (quote (("f:" "f:"))))
 '(ecb-tip-of-the-day nil)
 '(ecb-windows-width 0.25)
 '(inhibit-startup-screen t)
 '(markdown-command
   "pandoc -f markdown -t html -s --toc --template=default -N -S")
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(speedbar-default-position (quote left))
 '(tool-bar-mode nil))

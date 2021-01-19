{ pkgs, lib, config, ... }: {

  imports = [
    ./emacs-init.nix
  ];

  programs.emacs.init = {
    enable = true;
    recommendedGcSettings = true;

    earlyInit = ''
      ;; Disable some GUI distractions. We set these manually to avoid starting
      ;; the corresponding minor modes.
      (push '(menu-bar-lines . 0) default-frame-alist)
      (push '(tool-bar-lines . nil) default-frame-alist)
      (push '(vertical-scroll-bars . nil) default-frame-alist)
      (blink-cursor-mode 0)
    '';

    prelude = builtins.readFile ./prelude.el;
    postlude = builtins.readFile ./postlude.el;

    usePackage = {

      ace-window = {
        enable = true;
        command = [ "ace-window" ];
        bind = {
          "M-o" = "ace-window";
        };
        config = ''
          (setq aw-dispatch-alist
                '((?x aw-delete-window " Ace - Delete Window")
                (?m aw-swap-window " Ace - Swap Window")
                (?n aw-flip-window)
                (?v aw-split-window-vert " Ace - Split Vert Window")
                (?h aw-split-window-horz " Ace - Split Horz Window")
                (?i delete-other-windows " Ace - Maximize Window")
                (?o delete-other-windows)
                (?b balance-windows)))

          (add-to-list 'aw-dispatch-alist '(?w hydra-window-size/body) t)
          (add-to-list 'aw-dispatch-alist '(?\; hydra-window-frame/body) t)

          (ace-window-display-mode t)
        '';
      };

      async = {
        enable = true;
      };

      auctex = {
        enable = true;
        after = [ "tex" "latex" "writegood-mode" "olivetti" ];
        command = [ "latex-mode" "LaTeX-mode" "plain-tex-mode" ];
        mode = [ ''("\\.tex\\'" . LaTeX-mode)'' ];
        bindLocal = {
          LaTeX-mode-map = {
            "M-q" = "ales/fill-paragraph";
          };
        };
        config = builtins.readFile ./auctex-config.el;
      };

      avy = {
        enable = true;
        command = [ "avy-goto-char-timer" ];
        bind = {
          "C-:" = "avy-goto-char-timer";
        };
      };

      coffee-mode = {
        enable = true;
        mode = [ ''"\\.coffee\\'"'' ];
      };

      company = {
        enable = true;
        diminish = [ "company-mode" ];
        command = [ "company-mode" "company-doc-buffer" "global-company-mode" ];
        hook = [ "(after-init . global-company-mode)"];
        extraConfig = ''
          :bind (:map company-mode-map
                      ([remap completion-at-point] . company-complete-common)
                      ([remap complete-symbol] . company-complete-common))
        '';
        config = ''
          (setq company-show-numbers t
                company-tooltip-maximum-width 100
                company-tooltip-minimum-width 20
                ; Allow me to keep typing even if company disapproves.
                company-require-match nil)
        '';
      };

      company-org-roam = {
        enable = true;
        after = [ "org-roam" "company" ];
        config = "(push 'company-org-roam company-backends)";
      };

      consult = {
        enable = true;
        extraConfig = ''
          :bind
          ([remap goto-line] . consult-goto-line)
        '';
      };

      consult-flycheck = {
        enable = true;
      };

      consult-selectrum = {
        enable = true;
        after = [ "selectrum" ];
      };

      ctrlf = {
        enable = true;
        config = ''
          (ctrlf-mode 1)
        '';
      };

      # Instead of moving to column 0, move the the beginning of the
      # text on the line.
      crux = {
        enable = true;
        bind = {
          "C-a" = "crux-move-beginning-of-line";
        };
      };

      dash = { enable = true; };

      dashboard = {
        enable = true;
        config = ''
          (dashboard-setup-startup-hook)

          (setq dashboard-week-agenda t)

          ;; TODO: add the agenda for the current day that is more flexible than the default implementation in dashboard.el
          ;; The filter should take all agenda items for the current day and display them (including birthdays)
          (setq dashboard-items '((projects . 10)
                                  (recents . 10)))

          (setq dashboard-set-heading-icons t)
          (setq dashboard-set-file-icons t)

          (setq default-directory (concat (getenv "HOME") "/"))
        '';
      };

      dap-mode = {
        enable = true;
        after = [ "lsp-mode" ];
        command = [ "dap-mode" "dap-auto-configure-mode" ];
        config = ''
          (dap-auto-configure-mode)
        '';
      };

      dap-mouse = {
        enable = true;
        command = [ "dap-tooltip-mode" ];
      };

      dap-ui = {
        enable = true;
        after = [ "dap-mode" ];
        command = [ "dap-ui-mode" ];
        config = ''
          (dap-ui-mode t)
        '';
      };

      direnv = {
        enable = false;
        after = [ "warnings" ];
        config = ''
          (add-to-list 'warning-suppress-types '(direnv))
          (direnv-mode 1)
        '';
      };

      disable-mouse = {
        enable = true;
        config = "(global-disable-mouse-mode)";
      };

      doom-modeline = {
        enable = true;
        config = ''
          (doom-modeline-mode 1)
          (setq doom-modeline-buffer-file-name-style 'relative-from-project)
          (setq doom-modeline-height 15)
        '';
      };

      doom-themes = {
        enable = true;
        config = ''
          (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
                doom-themes-enable-italic t  ; if nil, italics is universally disabled

                ;;doom-one specific settings
                ;;doom-one-brighter-modeline nil
                doom-one-brighter-comments t
           )

          (load-theme 'doom-gruvbox t)

          ;; Corrects (and improves) org-mode's native fontification.
          ;;(doom-themes-org-config)
        '';
      };

      elm-mode = {
        enable = true;
        mode = [ ''"\\.elm\\'"'' ];
        command = [ "elm-mode" ];
        after = [ "company" ];
        hook = [ "(elm-mode . elm-format-on-save-mode)" ];
        extraPackages = [
          pkgs.elmPackages.elm-language-server
        ];
        config = ''
          (add-to-list 'company-backends 'company-elm)
        '';
      };

      emacsql = {
        enable = true;
      };

      emacsql-sqlite = {
        enable = true;
      };

      embark = {
        enable = true;
        bind = {
          "C-S-a" = "embark-act";
        };
        config = ''
          ;; For Selectrum users:
          (defun current-candidate+category ()
            (when selectrum-active-p
              (cons (selectrum--get-meta 'category)
                    (selectrum-get-current-candidate))))

          (add-hook 'embark-target-finders #'current-candidate+category)

          (defun current-candidates+category ()
            (when selectrum-active-p
              (cons (selectrum--get-meta 'category)
              (selectrum-get-current-candidates
              ;; Pass relative file names for dired.
              minibuffer-completing-file-name))))

          (add-hook 'embark-candidate-collectors #'current-candidates+category)

          ;; No unnecessary computation delay after injection.
          (add-hook 'embark-setup-hook 'selectrum-set-selected-candidate)
        '';
      };

      # embark-consult = {
      #   enable = true;
      #   after = [ "embark" "consult" ];
      # };

      envrc = {
        enable = true;
        after = [ "lsp-mode" ];
        bindKeyMap = {
          "C-c e" = "envrc-command-map";
        };
        config = ''
          (envrc-global-mode)
        '';
      };

      ess = {
        enable = true;
      };

      exec-path-from-shell = {
        enable = true;
        config = ''
          (setq exec-path-from-shell-variables '("PATH" "SHELL"))
          (setq exec-path-from-shell-arguments '("-l"))
          (exec-path-from-shell-initialize)
          (setenv "LANG" "en_US")
        '';
      };

      expand-region = {
        enable = true;
        bind = {
          "C-=" = "er/expand-region";
          "C-+" = "er/contract-region";
        };
      };

      f = { enable = true; };

      # Highlight TODO/FIXME within buffers (replace with tree-sitter?)
      fic-mode = {
        enable = true;
        hook = [ "(prog-mode)" ];
      };

      flycheck = {
        enable = true;
        diminish = [ "flycheck-mode" ];
        command = [ "global-flycheck-mode" ];
        bind = {
          "M-n" = "flycheck-next-error";
          "M-p" = "flycheck-previous-error";
        };
        config = ''
          ;; Only check buffer when mode is enabled or buffer is saved.
          (setq flycheck-check-syntax-automatically '(mode-enabled save))

          ;; Enable flycheck in all eligible buffers.
          (global-flycheck-mode)
        '';
      };

      flycheck-ledger = {
        enable = true;
        after = [ "ledger" ];
      };

      flyspell-correct = {
        enable = true;
        after = [ "flyspell" ];
        extraConfig = ''
          :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper))
        '';
      };

      haskell-mode = {
        enable = true;
        mode = [ ''"\\.hs\\'"'' ];
        config = ''
          (require 'haskell)
        '';
      };

      helpful = {
        enable = true;
        extraConfig = ''
          :bind
          ([remap describe-function] . helpful-callable)
          ([remap describe-command] . helpful-command)
          ([remap describe-variable] . helpful-variable)
          ([remap describe-key] . helpful-key)
        '';
      };

      hippie-expand = {
        enable = true;
        bind = {
          "M-/" = "hippie-expand";
        };
        config = ''
          (setq hippie-expand-try-functions-list
            '(try-expand-dabbrev
              try-expand-dabbrev-all-buffers
              try-expand-dabbrev-from-kill
              try-complete-file-name-partially
              try-complete-file-name
              try-expand-all-abbrevs
              try-expand-list
              try-expand-line
              try-complete-lisp-symbol-partially
              try-complete-lisp-symbol))
        '';
      };

      hl-todo = {
        enable = true;
      };

      hungry-delete = {
        enable = true;
        config = "(global-hungry-delete-mode)";
      };

      # Would be great to define these in the different use-package definitions
      hydra = {
        enable = true;
        config = ''
          (defhydra hydra-window-size (:color red)
            "Window size"
            ("h" shrink-window-horizontally "shrink horizontal")
            ("j" shrink-window "shrink vertical")
            ("k" enlarge-window "enlarge vertical")
            ("l" enlarge-window-horizontally "enlarge horizontal"))

          (defhydra hydra-window-frame (:color red)
            "Frame"
            ("f" make-frame "new frame")
            ("x" delete-frame "delete frame"))

          (defhydra hydra-olivetti-width (:color red)
            "Olivetti panel size"
            ("j" olivetti-shrink "shrink panel width")
            ("k" olivetti-expand "increase panel width")
            ("=" olivetti-set-width "specify panel width"))
        '';
      };

      ibuffer = {
        enable = true;
        bind = {
          "C-x C-b" = "ibuffer";
        };
        config = builtins.readFile ./ibuffer-config.el;
      };

      ledger-mode = {
        enable = true;
        mode = [ ''"\\.ledger\\'"'' ];
        config = ''
          (setq ledger-clear-whole-transactions 1)
          (setq ledger-reconcile-default-commodity "R")
        '';
      };

      lsp-diagnostics = {
        enable = true;
      };

      lsp-metals = {
        enable = true;
        defer = true;
        after = [ "lsp-mode" ];
      };

      lsp-mode = {
        enable = true;
        defer = true;
        after = [ "company" "flycheck" ];
        hook = [
          "(elm-mode . lsp-deferred)"
          "(scala-mode . lsp-deferred)"
          "(nix-mode . lsp-deferred)"
          "(lsp-mode . lsp-enable-which-key-integration)"
        ];
        config = ''
          (setq lsp-diagnostics-provider :flycheck)
          (setq lsp-enable-xref t)
          (setq lsp-headerline-breadcrumb-enable nil)

          ;; Performance adjustments (https://emacs-lsp.github.io/lsp-mode/page/performance/)
          (setq read-process-output-max (* 1024 1024)) ;; 1mb
          (setq lsp-completion-provider :capf)

          (push "[/\\\\]vendor$" lsp-file-watch-ignored)
          (push "[/\\\\]node_modules$" lsp-file-watch-ignored)
          (push "[/\\\\]\\.yarn$" lsp-file-watch-ignored)
          (push "[/\\\\]\\.direnv$" lsp-file-watch-ignored)
        '';
      };

      lsp-modeline = {
        enable = true;
        after = [ "lsp-mode" ];
      };

      lsp-ui = {
        enable = true;
        command = [ "lsp-ui-mode" ];
        config = ''
          (setq lsp-ui-doc-delay 2)

          (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
          (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references)
        '';
      };

      lsp-ui-flycheck = {
        enable = true;
        command = [ "lsp-flycheck-enable" ];
        after = [ "flycheck" "lsp-ui" ];
      };

      magit = {
        enable = true;
        bind = {
          "C-x g" = "magit-status";
        };
        config = ''
          ;; https://github.com/magit/magit/issues/2982#issuecomment-598493683
          (setq magit-git-executable (executable-find "git"))
          (add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)

          ;; Define a custom transient menu option to fetch updates from upstream and remove local
          ;; branches that not longer have a tracking branch on the remote
          (transient-insert-suffix 'magit-fetch "p"
            '("P" "fetch, prune and remove local branches tracking 'gone' remotes" gp/magit-fetch-and-prune-gone-remotes))

          ;; http://whattheemacsd.com/setup-magit.el-01.html#comment-748135498
          ;; full screen magit-status
          (defadvice magit-status (around magit-fullscreen activate)
            (window-configuration-to-register :magit-fullscreen)
            ad-do-it
            (delete-other-windows))

          (defun magit-quit-session ()
            "Restores the previous window configuration and kills the magit buffer"
            (interactive)
            (kill-buffer)
            (jump-to-register :magit-fullscreen))

          (define-key magit-status-mode-map (kbd "q") 'magit-quit-session)
        '';
      };

      marginalia = {
        enable = true;
        config = ''
          ;; Must be in the :init section of use-package such that the mode gets
          ;; enabled right away. Note that this forces loading the package.
          (marginalia-mode)

          ;; Enable richer annotations for M-x.
          ;; Only keybindings are shown by default, in order to reduce noise for this very common command.
          ;; * marginalia-annotate-symbol: Annotate with the documentation string
          ;; * marginalia-annotate-command-binding (default): Annotate only with the keybinding
          ;; * marginalia-annotate-command-full: Annotate with the keybinding and the documentation string
          ;; (setf (alist-get 'command marginalia-annotate-alist) #'marginalia-annotate-command-full)
        '';
      };

      modus-vivendi-theme = {
        enable = false;
      };

      multiple-cursors = {
        enable = true;
        bind = {
          "C-S-c C-S-c" = "mc/edit-lines";
          "C-c m" = "mc/mark-all-like-this";
          "C->" = "mc/mark-next-like-this";
          "C-<" = "mc/mark-previous-like-this";
        };
      };

      nix-mode = {
        enable = true;
        mode = [ ''"\\.nix\\'"'' ];
        after = [ "company" ];
        extraPackages = [
          pkgs.rnix-lsp
        ];
      };

      no-littering = {
        enable = true;
        demand = true;
        config = ''
          (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
        '';
      };

      olivetti = {
        enable = true;
        command = [ "olivetti-mode" ];
        diminish = [ "olivetti-mode" ];
        bindLocal = {
          olivetti-mode-map = {
            "C-M-=" = "hydra-olivetti-width/body";
          };
        };

        config = ''
          (setq olivetti-body-width 110)
          (setq olivetti-minimum-body-width 80)
          (setq olivetti-recall-visual-line-mode-entry-state t)

          ;; Enable hl-line-mode for olivetti-mode
          (push 'hl-line-mode olivetti-mode-on-hook)

          (add-hook 'poly-markdown+r-mode-hook
            (lambda()
              (push 'olivetti-mode polymode-move-these-vars-from-old-buffer) ;; Doesn't seem to work!
              (olivetti-mode t)))
        '';
      };

      orderless = {
        enable = true;
        config = ''
          (setq completion-styles '(orderless))
        '';
      };

      org = {
        enable = true;
        bind = {
          "C-c l" = "org-store-link";
          "C-c a" = "org-agenda";
          "C-C c" = "org-capture";
        };
        config = builtins.readFile ./org-config.el;
      };

      org-agenda = {
        enable = true;
        after = [ "org" ];
        defer = true;
        config = "(setq org-agenda-include-diary t)";
      };

      org-chef = {
        enable = true;
        after = [ "org" ];
        defer = 5; # defer loading for 5 seconds
      };

      # TODO: look into alternatives for org journal. Using dailies from org-roam??
      org-journal = {
        enable = true;
        after = [ "org" ];
        bind = {
          "C-c n j" = "org-journal-new-entry";
        };
        config = ''
          (setq org-journal-enable-agenda-integration t
                org-journal-file-type 'monthly)

          (setq org-journal-dir org-notes-directory)
          ;;(org-journal-date-prefix "* ")
          (setq org-journal-file-format "%Y-%m-%d.org")
          (setq org-journal-date-format "%A, %d %B %Y")


          (defun org-journal-file-header-func (time)
            "Custom function to create journal header."
            (concat
              (pcase org-journal-file-type
                (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
                (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
                (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
                (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))

          (setq org-journal-file-header 'org-journal-file-header-func)
        '';
      };

      # TODO verify the config for org-noter
      org-noter = {
        enable = false;
        command = [ "org-noter" ];
        after = [ "org" "pdf-view" ];
        config = ''
          (setq org-noter-notes-window-location 'other-frame         ; The WM can handle splits
                org-noter-always-create-frame nil                    ; Please stop opening frames
                org-noter-hide-other nil                             ; I want to see the whole file
                org-noter-notes-search-path (list org_notes)         ; Everything is relative to the main notes file
                org-noter-default-notes-file-names '("notes.org")
                org-noter-separate-notes-from-heading t
          )
        '';
      };

      org-roam = {
        enable = true;
        after = [ "emacsql" "emacsql-sqlite" ];
        hook = [ "(after-init . org-roam-mode)" ];
        bind = {
          "C-c n l" = "org-roam";
          "C-c n t" = "org-roam-dailies-find-today";
          "C-c n f" = "org-roam-find-file";
          "C-c n i" = "org-roam-insert";
          "C-c n g" = "org-roam-graph";
        };
        extraPackages = [ pkgs.sqlite ];
        config = ''
          (setq org-roam-directory org-notes-directory)
          (setq org-roam-db-location (f-join org-root-directory "org-roam.db"))
          (setq org-roam-graph-executable "${pkgs.graphviz}/bin/dot")
          (setq org-roam-list-files-commands '(elisp)) ; Use elisp to recurse the current directory
        '';
      };

      org-roam-bibtex = { # TODO: complete this
        enable = false;
      };

      org-superstar = {
        enable = true;
        after = [ "org" ];
        hook = [ "(org-mode . (lambda () (org-superstar-mode 1)))" ];
      };

      page-break-lines = {
        enable = true;
        diminish = [ "page-break-lines-mode" ];
      };

      pcre2el = {
        enable = true;
        config = "(pcre-mode)";
      };

      poly-R = {
        enable = true;
        after = [ "polymode" "ess" ];
      };

      poly-noweb = {
        enable = true;
        after = [ "polymode" ];
      };

      # poly-latex-R = {
      #   enable = true;
      #   after = [ "polymode" ];
      #   config = ''
      #     (add-to-list 'LaTeX-verbatim-environments "Rcode")
      #   '';
      # };

      polymode = {
        enable = true;
        mode = [
          ''("\\.Rnw\\'" . poly-noweb+r-mode)''
          ''("\\.Rtex\\'" . poly-noweb+r-mode)''
          ''("\\.Rlatex\\'" . poly-latex+R-mode)''
        ];
      };

      popup-kill-ring = {
        enable = true;
        command = [ "popup-kill-ring" ];
        bind = {
          "M-y" = "popup-kill-ring";
        };
      };

      projectile = {
        enable = true;
        diminish = [ "projectile-mode" ];
        command = [ "projectile-mode" "projectile-project-root" ];
        bindKeyMap = {
          "C-c p" = "projectile-command-map";
        };
        config = ''
          (setq projectile-completion-system 'default)
          (setq projectile-indexing-method 'alien)
          (setq projectile-switch-project-action 'magit-status)
          (setq projectile-git-submodule-command nil) ;; Stupid submodule bullshit

          ;; Always ignore node_modules
          (push "node_modules" projectile-globally-ignored-directories)
          (push ".yarn" projectile-globally-ignored-directories)

          (projectile-mode +1)
        '';
      };

      pulse = {
        enable = true;
        config = ''
          (defun pulse-line (&rest _)
            "Pulse the current line."
            (pulse-momentary-highlight-one-line (point)))

          (dolist (command '( ;; scroll-up-command scroll-down-command
                             recenter-top-bottom other-window ace-window))
            (advice-add command :after #'pulse-line))
        '';
      };

      rainbow-delimiters = {
        enable = true;
        diminish = [ "rainbow-delimiters-mode" ];
        hook = [
          "(prog-mode . rainbow-delimiters-mode)"
          "(TeX-update-style . rainbow-delimiters-mode)"
        ];
        config = ''
          (set-face-attribute 'rainbow-delimiters-unmatched-face nil
                              :foreground "red"
                              :inherit 'error
                              :box t)
        '';
      };

      restclient = {
        enable = true;
        command = [ "rectclient-mode" ];
      };

      rg = {
        enable = true;
        after = [ "wgrep" ];
        extraPackages = [ pkgs.ripgrep ];
        config = ''
          (rg-enable-default-bindings)

          (rg-define-search gp/rg-vc-or-dir
            :query ask
            :format regexp
            :files "everything"
            :dir (let ((vc (projectile-project-root)))
                   (if vc
                       vc                  ; search root project directory
                     default-directory))   ; or from the current directory
            :confirm prefix
            :flags ("--hidden --smart-case -g !.git -g '!**/node_modules/**'")
            :menu ("Custom" "k" "Project from root"))
        '';
      };

      s = { enable = true; };

      scala-mode = {
        enable = true;
        mode = [
          ''("\\.scala\\'" . scala-mode)''
          ''("\\.sbt\\'" . scala-mode)''
        ];
        extraPackages = [
          pkgs.metals # language server
        ];
      };

      selectrum = {
        enable = true;
        config = ''
          (setq selectrum-refine-candidates-function #'orderless-filter)
          (setq selectrum-highlight-candidates-function #'orderless-highlight-matches)
          (selectrum-mode +1)
        '';
      };

      selectrum-prescient = {
        enable = true;
        after = [ "selectrum" ];
        config = ''
          ;; to make sorting and filtering more intelligent
          (selectrum-prescient-mode +1)

          ;; to save your command history on disk, so the sorting gets more
          ;; intelligent over time
          (prescient-persist-mode +1)
        '';
      };

      # Manage the ssh-agent on the system by loading identities if and when required
      ssh-agency = {
        enable = true;
      };

      warnings = { #TODO: needed?
        enable = true;
      };

      wgrep = {
        enable = true;
      };

      which-key = {
        enable = true;
        config = ''
          ;; Allow C-h to trigger which-key before it is done automatically
          (setq which-key-show-early-on-C-h t)

          ;; make sure which-key doesn't show normally but refreshes quickly after it is triggered.
          (setq which-key-idle-delay 10000)
          (setq which-key-idle-secondary-delay 0.05)
          (which-key-mode 1)
        '';
      };

      writegood-mode = {
        enable = true;
        config = ''
          (add-hook 'TeX-update-style-hook #'writegood-mode)
          (add-to-list 'writegood-weasel-words "actionable")
        '';
      };

      yaml-mode = {
        enable = true;
        mode = [ ''"\\.ya?ml\\'"'' ];
      };

      yasnippet = {
        enable = true;
        diminish = [ "yas-minor-mode" ];
        command = [ "yas-global-mode" "yas-minor-mode" "yas-expand-snippet" ];
        hook = [
          # Yasnippet interferes with tab completion in ansi-term.
          "(term-mode . (lambda () (yas-minor-mode -1)))"
          "(yas-minor-mode . (lambda () (yas-activate-extra-mode 'fundamental-mode)))"
        ];
        config = "(yas-global-mode 1)";
      };

      yasnippet-snippets = {
        enable = true;
        after = [ "yasnippet" ];
      };
    };
  };
}

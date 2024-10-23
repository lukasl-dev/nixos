(defvar *catppuccin-mocha-colors*
  '(:rosewater "#F5E0DC"
    :flamingo  "#F2CDCD"
    :pink      "#F5C2E7"
    :mauve     "#CBA6F7"
    :red       "#F38BA8"
    :maroon    "#EBA0AC"
    :peach     "#FAB387"
    :yellow    "#F9E2AF"
    :green     "#A6E3A1"
    :teal      "#94E2D5"
    :sky       "#89DCEB"
    :sapphire  "#74C7EC"
    :blue      "#89B4FA"
    :lavender  "#B4BEFE"
    :text      "#CDD6F4"
    :subtext1  "#BAC2DE"
    :subtext0  "#A6ADC8"
    :overlay2  "#9399B2"
    :overlay1  "#7F849C"
    :overlay0  "#6C7086"
    :surface2  "#585B70"
    :surface1  "#45475A"
    :surface0  "#313244"
    :base      "#1E1E2E"
    :mantle    "#181825"
    :crust     "#11111B"))

(defvar *search-engines*
  (list
     '("google" "https://google.com/search?q=~a" "https://google.com")
     '("python3" "https://docs.python.org/3/search.html?q=~a" "https://docs.python.org/3")
     '("doi" "https://dx.doi.org/~a" "https://dx.doi.org/")
   )
)

(define-configuration context-buffer
  "Go through the search engines above and make-search-engine out of them."
  ((search-engines
    (append
     (mapcar (lambda (engine) (apply 'make-search-engine engine))
             *search-engines*)
     %slot-default%))))

(define-configuration browser
  ((theme
    (make-instance 'theme:theme
      :background-color (getf *catppuccin-mocha-colors* :base)
      :text-color       (getf *catppuccin-mocha-colors* :text)
      :primary-color    (getf *catppuccin-mocha-colors* :blue)
      :secondary-color  (getf *catppuccin-mocha-colors* :surface0)
      :action-color     (getf *catppuccin-mocha-colors* :sapphire)
      :highlight-color  (getf *catppuccin-mocha-colors* :mauve)
      :success-color    (getf *catppuccin-mocha-colors* :green)
      :warning-color    (getf *catppuccin-mocha-colors* :yellow)
      :error-color      (getf *catppuccin-mocha-colors* :red)
      :contrast-text-color (getf *catppuccin-mocha-colors* :surface0)
      :codeblock-color     (getf *catppuccin-mocha-colors* :surface1)))))

(define-configuration (hint-mode)
  ((style
    (theme:themed-css (theme *browser*)
      (:root
       :background-color "rgba(30, 30, 46, 0.925)")
      (".nyxt-hint"
       :background-color "#89B4FA"
       :color "#11111B"
       :border "1px solid #11111B"
       :padding "1px 2px"
       :border-radius "4px"
       :font-size "12px")))))

(define-configuration (web-buffer)
  ((default-modes (pushnew 'nyxt/mode/style:dark-mode %slot-value%))))

(define-configuration (web-buffer)
  ((default-modes (pushnew 'nyxt/mode/blocker:blocker-mode %slot-value%))))

(define-configuration (input-buffer)
  ((default-modes (pushnew 'nyxt/mode/vi:vi-normal-mode %slot-value%))))

(define-configuration (prompt-buffer)
  ((default-modes (pushnew 'nyxt/mode/vi:vi-insert-mode %slot-value%))))

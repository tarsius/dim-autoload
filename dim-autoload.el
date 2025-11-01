;;; dim-autoload.el --- Dim or hide autoload cookie lines  -*- lexical-binding:t -*-

;; Copyright (C) 2013-2025 Jonas Bernoulli

;; Author: Jonas Bernoulli <emacs.dim-autoload@jonas.bernoulli.dev>
;; Homepage: https://github.com/tarsius/dim-autoload
;; Keywords: convenience

;; Package-Version: 2.1.1
;; Package-Requires: (
;;     (emacs  "26.1")
;;     (compat "30.1"))

;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation, either version 3 of the License,
;; or (at your option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this file.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Dim or hide autoload cookie lines.

;; Unlike the built-in font-lock keyword which only changes the
;; appearance of the "autoload" substring of the autoload cookie
;; line and repurposes the warning face also used elsewhere, the
;; keyword added here changes the appearance of the complete line
;; using a dedicated face.

;; That face is intended for dimming.  While you are making sure
;; your library contains all the required autoload cookies you can
;; just turn the mode off.

;; To install the dimming keywords add this to your init file:
;;
;;    (global-dim-autoload-cookies-mode 1)

;; You might even want to dim the cookie lines some more by using
;; a foreground color in `dim-autoload-cookies-line' that is very
;; close to the `default' background color.

;; Additionally this package provides a mode which completely hides
;; autoload cookies.  To hide autoload cookies in the current buffer
;; use `hide-autoload-cookies-mode'.  A globalized mode also exists,
;; but its use is discouraged.  Also note that it doesn't make sense
;; to enable both global modes at the same time, or to enable both
;; local modes in the same buffer.

;; Use the command `cycle-autoload-cookies-visibility' to cycle
;; between the three possible styles in the current buffer, like
;; so:
;;
;;    ,-> Show -> Dim -> Hide -.
;;    '------------------------'


;;; Code:

(require 'compat)

(defgroup dim-autoload nil
  "Dim complete autoload cookie lines."
  :group 'font-lock-extra-types
  :group 'faces)

;;; Dim Mode

(defface dim-autoload-cookie-line
  '((t (:inherit shadow)))
  "Face for autoload cookie lines.
This face is only used when the appropriate font-lock keyword
for autoload cookie lines has been installed.  To do so enable
`global-dim-autoload-cookies-mode'."
  :group 'dim-autoload)

(defcustom dim-autoload-cookie-line-style 'dim-autoload-font-lock-keywords-1
  "The font-lock keywords used for autoload cookie lines.
After changing the value of this option the mode has to
be turned off and then on again."
  :group 'dim-autoload
  :type '(choice (const :tag "just dim"
                        dim-autoload-font-lock-keywords-1)
                 (const :tag "dim and hide arguments"
                        dim-autoload-font-lock-keywords-2)))

(defconst dim-autoload-font-lock-keywords-1
  '(("^;;;###[-a-z]*autoload.*$" 0 'dim-autoload-cookie-line t)))

(defconst dim-autoload-font-lock-keywords-2
  '(("^;;;###[-a-z]*autoload\\(?: (\\(.+\\))\\)?$"
     (0 'dim-autoload-cookie-line t)
     (1 '( face      dim-autoload-cookie-line
           invisible dim-autoload)
        t t))))

(defvar dim-autoload-cookies-mode-lighter "")

;;;###autoload
(define-minor-mode dim-autoload-cookies-mode
  "Toggle dimming autoload cookie lines.
You likely want to enable this globally
using `global-dim-autoload-cookies-mode'."
  :lighter dim-autoload-cookies-mode-lighter
  :group 'dim-autoload
  (cond (dim-autoload-cookies-mode
         (when (eq dim-autoload-cookie-line-style
                   'dim-autoload-font-lock-keywords-2)
           (add-to-invisibility-spec 'dim-autoload)
           (add-to-list (make-local-variable 'font-lock-extra-managed-props)
                        'invisible))
         (font-lock-add-keywords
          nil (symbol-value dim-autoload-cookie-line-style) 'end))
        (t
         (font-lock-remove-keywords nil dim-autoload-font-lock-keywords-1)
         (font-lock-remove-keywords nil dim-autoload-font-lock-keywords-2)))
  (font-lock-flush))

;;;###autoload
(define-globalized-minor-mode global-dim-autoload-cookies-mode
  dim-autoload-cookies-mode turn-on-dim-autoload-cookies-mode-if-desired)

;;;###autoload
(defun turn-on-dim-autoload-cookies-mode-if-desired ()
  (when (derived-mode-p 'emacs-lisp-mode)
    (dim-autoload-cookies-mode 1)))

;;; Hide Mode

(defconst hide-autoload-font-lock-keywords
  '(("^\n;;;###[-a-z]*autoload.*" 0 '(face nil invisible dim-autoload) t)))

(defvar hide-autoload-cookies-mode-lighter " HAuto")

;;;###autoload
(define-minor-mode hide-autoload-cookies-mode
  "Toggle hiding autoload cookie lines.
You likely want to enable this globally
using `global-hide-autoload-cookies-mode'."
  :lighter hide-autoload-cookies-mode-lighter
  :group 'dim-autoload
  (cond (hide-autoload-cookies-mode
         (add-to-invisibility-spec 'dim-autoload)
         (add-to-list (make-local-variable 'font-lock-extra-managed-props)
                      'invisible)
         (font-lock-add-keywords nil hide-autoload-font-lock-keywords 'end))
        (t
         (font-lock-remove-keywords nil hide-autoload-font-lock-keywords)))
  (font-lock-flush))

;;;###autoload
(define-globalized-minor-mode global-hide-autoload-cookies-mode
  hide-autoload-cookies-mode turn-on-hide-autoload-cookies-mode-if-desired)

;;;###autoload
(defun turn-on-hide-autoload-cookies-mode-if-desired ()
  (when (derived-mode-p 'emacs-lisp-mode)
    (hide-autoload-cookies-mode 1)))

;;; Cycle Visibility

(defun cycle-autoload-cookies-visibility ()
  "Cycle between dimming, hiding, and showing autoload cookies.

 ,-> Show -> Dim -> Hide -.
 '------------------------'

See `dim-autoload-cookies-mode'
and `hide-autoload-cookies-mode'."
  (interactive)
  (cond (dim-autoload-cookies-mode
         (dim-autoload-cookies-mode  -1)
         (hide-autoload-cookies-mode  1))
        (hide-autoload-cookies-mode
         (dim-autoload-cookies-mode  -1)
         (hide-autoload-cookies-mode -1))
        (t
         (dim-autoload-cookies-mode   1)
         (hide-autoload-cookies-mode -1))))

;;; _
(provide 'dim-autoload)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; dim-autoload.el ends here

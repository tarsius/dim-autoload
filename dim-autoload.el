;;; dim-autoload.el --- dim complete autoload cookie lines

;; Copyright (C) 2013  Jonas Bernoulli

;; Author: Jonas Bernoulli <jonas@bernoul.li>
;; Version: 1.0.0
;; Homepage: http://github.com/tarsius/dim-autoload
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Dim autoload cookies.

;; Unlike the built-in font-lock keyword which only changes the
;; appearance of the "autoload" substring of the autoload cookie
;; line and repurposes the warning face also used elsewhere, the
;; keyword added here changes the appearance of the complete line
;; using a dedicated face.

;; That face is intended for dimming.  While you are making sure
;; your library contains all the required autoload cookies you can
;; just turn it off.

;; To install the keywords add this to your init file:
;;
;;    (global-dim-autoload-cookies-mode 1)

;; You might also want to dim the cookie lines even more by using
;; a foreground color in `dim-autoload-cookies-line' that is very
;; close to the `default' background color.

;;; Code:

(defgroup dim-autoload nil
  "Dim complete autoload cookie lines."
  :group 'convenience
  :group 'faces)

(defface dim-autoload-cookie-line
  '((t (:inherit shadow)))
  "Face for autoload cookie lines.
This face is only used when the appropriate font-lock keyword
for autoload cookie lines has been installed.  To do so enable
`global-dim-autoload-cookies-mode'."
  :group 'dim-autoload)

(defconst dim-autoload-font-lock-keywords-1
  '(("^;;;###[-a-z]*autoload.*$" 0 'dim-autoload-cookie-line t)))

(defvar dim-autoload-cookies-mode-lighter "")

;;;###autoload
(define-minor-mode dim-autoload-cookies-mode
  "Toggle dimming autoload cookie lines.
You likely want to enable this globally
using `global-dim-autoload-cookies-mode'."
  :lighter dim-autoload-cookies-mode-lighter
  (if dim-autoload-cookies-mode
      (font-lock-add-keywords  nil dim-autoload-font-lock-keywords-1 'end)
    (font-lock-remove-keywords nil dim-autoload-font-lock-keywords-1))
  (font-lock-fontify-buffer))

;;;###autoload
(define-globalized-minor-mode global-dim-autoload-cookies-mode
  dim-autoload-cookies-mode turn-on-dim-autoload-cookies-mode-if-desired)

;;;###autoload
(defun turn-on-dim-autoload-cookies-mode-if-desired ()
  (when (derived-mode-p 'emacs-lisp-mode)
    (dim-autoload-cookies-mode 1)))

;; Ps: This is a lot of boilerplate; the same could be
;;     achieved using half a dozen lines in your init file.

(provide 'dim-autoload)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; dim-autoload.el ends here

;;; helm-company.el --- Helm interface for company-mode

;; Copyright (C) 2013 Yasuyuki Oka <yasuyk@gmail.com>

;; Author: Yasuyuki Oka <yasuyk@gmail.com>
;; Version: 0.1
;; URL: https://github.com/yasuyk/helm-company
;; Package-Requires: ((helm "1.0") (company "0.6.12"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Add the following to your Emacs init file:
;;
;; (autoload 'helm-company "helm-company") ;; Not necessary if using ELPA package
;; (eval-after-load 'company
;;   '(progn
;;      (define-key company-mode-map (kbd "C-:") 'helm-company)
;;     '(define-key company-active-map (kbd "C-:") 'helm-company)))

;;; Code:

(require 'helm)
(require 'helm-match-plugin)
(require 'helm-files)
(require 'helm-elisp) ;; For with-helm-show-completion
(require 'company)

(defgroup helm-company nil
  "Helm interface for company-mode."
  :prefix "helm-company-"
  :group 'helm)

(defcustom helm-company-candidate-number-limit 300
  "Limit candidate number of `helm-company'.

Set it to nil if you don't want this limit."
  :group 'helm-company
  :type '(choice (const :tag "Disabled" nil) integer))

(defun helm-company-init ()
  "Prepare helm for company."
  (helm-attrset 'company-candidates company-candidates)
  (helm-attrset 'company-prefix company-prefix)
  (when (<= (length company-candidates) 1)
    (helm-exit-minibuffer))
  (company-abort))

(defun helm-company-action (candidate)
  "Insert CANDIDATE."
  (delete-char (- (length (helm-attr 'company-prefix))))
  (insert candidate)
  ;; for GC
  (helm-attrset 'company-candidates nil))

(defvar helm-source-company-candidates
  '((name . "Company")
    (init . helm-company-init)
    (candidates . (lambda () (helm-attr 'company-candidates)))
    (action . helm-company-action)
    (persistent-action . t) ;; Disable persistent-action
    (persistent-help . "DoNothing")
    (company-candidates)))

;;;###autoload
(defun helm-company ()
  "Select `company-complete' candidates by `helm'.
It is useful to narrow candidates."
  (interactive)
  (unless company-candidates
    (company-complete))
  (when company-point
    (let ((begin (- company-point (length company-prefix))))
      (with-helm-show-completion begin company--point-max
        (helm :sources 'helm-source-company-candidates
              :buffer  "*helm company*"
              :candidate-number-limit helm-company-candidate-number-limit)))))

(provide 'helm-company)

;; Local Variables:
;; coding: utf-8
;; eval: (checkdoc-minor-mode 1)
;; End:

;;; helm-company.el ends here

;;; helm-tramp.el --- Tramp with helm interface -*- lexical-binding: t; -*-

;; Copyright (C) 2017 by masasam

;; Author: masasam
;; URL: https://github.com/masasam/emacs-helm-tramp
;; Version: 0.01
;; Package-Requires: ((helm "1.7.7"))

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

;; tramp with helm interface

;;; Code:

(require 'helm)
(require 'cl-lib)

(defgroup helm-tramp nil
  "tramp generator command with helm interface"
  :group 'helm)

(defcustom helm-tramp-limit 10
  "Limit of menu"
  :group 'helm-tramp)

(defun helm-tramp--candidates ()
  (let ((source (split-string
                 (with-temp-buffer
                   (insert-file-contents "~/.ssh/config")
                   (buffer-string))
                 "\n"))
        (hosts (list)))
    (dolist (host source)
      (when (string-match "[H\\|h]ost +\\(.+?\\)$" host)
        (setq host (substring host (match-beginning 1) (match-end 2)))
	(if (string-match "[ \t\n\r]+\\'" host)
	    (replace-match "" t t host))
	(if (string-match "\\`[ \t\n\r]+" host)
	    (replace-match "" t t host))
        (unless (string= host "*")
          (add-to-list
           'hosts
	   (concat "/" tramp-default-method ":" host ":/") t)
	  (add-to-list
           'hosts
	   (concat "/" tramp-default-method ":" host "|sudo:" host ":/") t)
	  )))
    hosts))


(defun helm-tramp-open (path)
  "Tramp open.  PATH is path."
  (find-file path))

(defvar helm-tramp--source
  (helm-build-sync-source "Tramp"
    :candidates #'helm-tramp--candidates
    :volatile t
    :action (helm-make-actions
             "Tramp" #'helm-tramp-open
             "Insert" #'insert)))

;;;###autoload
(defun helm-tramp ()
  (interactive)
  (helm :sources '(helm-tramp--source) :buffer "*helm tramp*"))

(provide 'helm-tramp)

;;; helm-tramp.el ends here

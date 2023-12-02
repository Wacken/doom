;;; local_file.el -*- lexical-binding: t; -*-

(defun org-cycle-hide-drawers (state)
  "Re-hide all drawers after a visibility state change."
  (when (and (derived-mode-p 'org-mode)
             (not (memq state '(overview folded contents))))
    (save-excursion
      (let* ((globalp (memq state '(contents all)))
             (beg (if globalp
                      (point-min)
                    (point)))
             (end (if globalp
                      (point-max)
                    (if (eq state 'children)
                        (save-excursion
                          (outline-next-heading)
                          (point))
                      (org-end-of-subtree t)))))
        (goto-char beg)
        (while (re-search-forward org-drawer-regexp end t)
          (save-excursion
            (beginning-of-line 1)
            (when (looking-at org-drawer-regexp)
              (let* ((start (1- (match-beginning 0)))
                     (limit
                      (save-excursion
                        (outline-next-heading
                         (point))))
                     (msg (format
                           (concat
                            "org-cycle-hide-drawers:  "
                            "`:END:`"
                            " line missing at position %s")
                           (1+ start))))
                (if (re-search-forward "^[ \t]*:END:" limit t)
                    (outline-flag-region start (point-at-eol) t)
                  (user-error msg))))))))))

(defun bh/org-agenda-to-appt () ; Erase all reminders and rebuilt reminders for today from the agenda
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

(defun org-journal-find-location ()
  ;; Open today's journal, but specify a non-nil prefix argument in order to
  ;; inhibit inserting the heading; org-capture will insert the heading.
  (org-journal-new-entry t)
  (unless (eq org-journal-file-type 'daily)
    (org-narrow-to-subtree))
  (goto-char (point-max)))

(defun org-roam-server-open ()
  "Ensure the server is active, then open the roam graph."
  (interactive)
  (org-roam-server-mode)
  (browse-url-xdg-open (format "http://localhost:%d" org-roam-server-port)))

(defun suppress-messages (old-fun &rest args)
  (cl-flet ((silence (&rest args1) (ignore)))
    (advice-add 'message :around #'silence)
    (unwind-protect
        (apply old-fun args)
      (advice-remove 'message #'silence))))

(defun my-csharp-repl ()
  "switch to the csharprepl buffer, creating it if necessary."
  (interactive)
  (if-let ((buf (get-buffer "*csharprepl*")))
      (pop-to-buffer buf)
    (when-let ((b (make-comint "csharprepl" "csharp")))
      (switch-to-buffer-other-window b))))

(defun my/org-add-ids-to-headlines-in-file ()
  "Add ID properties to all headlines in the current file which
do not already have one."
  (interactive)
  (org-map-entries 'org-id-get-create))

(provide 'local_file)

(require 'cl) 

(defun shortcut-trainer-days-since-epoch ()
  (interactive)
  (floor (/ (float-time (current-time)) 86400)))

(setq shortcut-trainer-file "~/.emacs.d/git/shortcut-trainer/shortcut-list.el")

(defun shortcut-trainer-write-to-file (shortcut-list)
  (interactive)
  (with-temp-file shortcut-trainer-file
    (dolist (i shortcut-list)
      (insert (format "%s" i))
      (insert "\n"))))

(defun shortcut-trainer-read-from-file (filename)
  (interactive)
  (setq shortcut-trainer-list '())
  (save-window-excursion 
    (find-file filename) 
    (goto-char (point-min))
    (while (not (eobp))
      (add-to-list 'shortcut-trainer-list (read (thing-at-point 'line)))
      (forward-line 1))))

(defun shortcut-trainer-train (shortcut)
  (interactive)
  (if (>= (shortcut-trainer-days-since-epoch) (+ (- (expt 2 (nth 2 shortcut)) 1) (nth 3 shortcut)))
      (let ((iteration (length (nth 1 shortcut))))
        (dolist (list-item (nth 1 shortcut))
          (let ((key (read-key (nth 0 shortcut))))
            (if (= key list-item)
                ;;Correct
                (progn 
                  (setq iteration (- iteration 1))
                  (if (= iteration 0)
                      (progn 
                        (message "%s" (propertize "Correct" 'face 'custom-saved))
                        (sleep-for 0.2)
                        (cl-return (list (concat "\"" (nth 0 shortcut) "\"")
                                         (nth 1 shortcut)
                                         (+ 1 (nth 2 shortcut))
                                         (shortcut-trainer-days-since-epoch))))))

              ;;Incorrect
              (progn
                (message "%s" (propertize "Incorrect" 'face 'custom-invalid))
                (sleep-for 0.2)
                (cl-return (list (concat "\"" (nth 0 shortcut) "\"")
                                 (nth 1 shortcut)
                                 0 
                                 (shortcut-trainer-days-since-epoch))))
              ))))
    (list (concat "\"" (nth 0 shortcut) "\"")
          (nth 1 shortcut)
          (nth 2 shortcut)
          (nth 3 shortcut))))

(shortcut-trainer-read-from-file shortcut-trainer-file)

(defun shortcut-trainer-drill ()
  (interactive)
  (shortcut-trainer-write-to-file 
   (mapcar #'shortcut-trainer-train shortcut-trainer-list)))

(defun shortcut-trainer-set ()
  (interactive)
  (setq old-shortcut (split-string (thing-at-point 'line) "||"))
  (setq new-shortcut '())
  ;;Description
  (add-to-list 'new-shortcut (nth 0 old-shortcut))
  ;; (add-to-list 'new-shortcut (concat "\"" (nth 0 old-shortcut) "\""))
  ;;Shortcuts
  (setq user-key 0)
  (setq key-list '())
  (while (not (= user-key 134217752))
    (setq user-key (read-key (concat "Enter key (" (nth 1 old-shortcut) "): ")))
    (setq key-list (append key-list (list user-key))))
  (setq key-list (butlast key-list 1))
  (add-to-list 'new-shortcut key-list t)
  ;; Date last reviewed
  (if (> (length old-shortcut) 2)
      (progn
        (setq date-string (nth 2 old-shortcut))
        (let ((day (string-to-number (substring date-string 8)))
              (month (string-to-number (substring date-string 5 7)))
              (year (string-to-number (substring date-string 0 4))))
          (add-to-list 'new-shortcut (floor (/ (float-time (encode-time 0 0 0 day month year)) 86400)) t))))
  ;;Successes
  (if (> (length old-shortcut) 3)
      (progn
        (add-to-list 'new-shortcut (floor (log (string-to-number (nth 3 old-shortcut)) 2)) t)
        ))
  (write-region (concat (format "%s" new-shortcut) "\n") nil shortcut-trainer-file 'append)

  ;; (write-region "append\n" nil shortcut-trainer-file 'append)
  )


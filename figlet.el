;;; figlet definitions for Emacs.  (C) Martin Giese
;;;
;;; Use this to separate sections in TeX files, Program source, etc.
;;;
;;; customize the figlet-font-dir variable below to point to your
;;; figlet font directory.
;;;
;;; M-x figlet      to get a figlet in standard font.
;;; C-u M-x figlet  to be asked for the font first.
;;; M-x banner      for an old-fashioned banner font.
;;; M-x toilet      to get a toilet in standard font.
;;;
;;; If you want to wrap the figlet output in comments:
;;; M-x figlet-comment-region
;;;

;;;  _____ ___ ____ _      _     ____  _          __  __
;;; |  ___|_ _/ ___| | ___| |_  / ___|| |_ _   _ / _|/ _|
;;; | |_   | | |  _| |/ _ \ __| \___ \| __| | | | |_| |_
;;; |  _|  | | |_| | |  __/ |_   ___) | |_| |_| |  _|  _|
;;; |_|   |___\____|_|\___|\__| |____/ \__|\__,_|_| |_|


;; (defconst figlet-font-dir "/usr/share/figlet")
(defconst figlet-font-file-regexp "\\.flf$")
(defconst figlet-match-font-name-regexp "^\\([^.]*\\)\\.flf$")

(defun figlet-font-name-for-file (filename)
  (string-match figlet-match-font-name-regexp filename)
  (match-string 1 filename))

(defun figlet-font-names (program)
  (mapcar 'figlet-font-name-for-file
	  (directory-files (figlet-font-dir program) nil figlet-font-file-regexp)))

(defun figlet-font-dir (program)
  (string-trim
   (with-output-to-string
     (call-process program nil standard-output nil "-I" "2"))))

(defun read-figlet-font (program prompt)
  (let* ((figlet-fonts (figlet-font-names program))
	 (font-alist (mapcar (lambda (x) (list x)) figlet-fonts)))
    (completing-read prompt font-alist)))

(defun call-figlet (font string)
  (figlet-call-process "figlet" font string))

(defun call-toilet (font string)
  (figlet-call-process "toilet" font string))

(defun figlet-call-process (program font string)
  (push-mark)
  (call-process program nil (current-buffer) nil
		"-f" (if (null font) "standard" font)
		string
		)
  (exchange-point-and-mark))

(defun figlet-comment-region ()
  (interactive
   (comment-region
    (region-beginning) (region-end)
	(if (member major-mode
			    '(emacs-lisp-mode
				  lisp-mode
				  scheme-mode))
		3			; 3 semicolons for lisp
	  nil))))

(defun figlet (s &optional font)
  (interactive
   (if current-prefix-arg
       (let
	   ((font (read-figlet-font "figlet" "Font: "))
	    (text (read-string "FIGlet Text: ")))
	 (list text font))
     (list (read-string "FIGlet Text: ") nil)))
  (save-excursion
    (call-figlet font s)))

(defun toilet (s &optional font)
  (interactive
   (if current-prefix-arg
       (let
	   ((font (read-figlet-font "toilet" "Font: "))
	    (text (read-string "Toilet Text: ")))
	 (list text font))
     (list (read-string "Toilet Text: ") nil)))
  (save-excursion
    (call-toilet font s)))

(defun banner (s)
  (interactive "sBanner Text: ")
  (figlet s "banner"))

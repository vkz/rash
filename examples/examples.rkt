#lang racket

(current-directory "/Users/vkz/work/rash/examples")
(define-syntax-rule (make-script shell-version body)
  (begin
    (printf "~a\n" shell-version)
    (lambda ()
      (parameterize ((current-directory
                      (build-path (current-directory) "tests/")))
        (begin body)))))

;; (run (md5 -q README.md) (> README.md.md5))
;; ------------------------------------------
(define md5-script
  (make-script
   "(run (md5 -q README.md) (> README.md.md5))"

   (begin
     (define md5 (find-executable-path "md5" #f))
     (define infile "README.md")
     (define outfile "README.md.md5")
     (parameterize
         ([current-custodian (make-custodian)])
       (current-subprocess-custodian-mode #f)
       (define to (open-output-file outfile #:mode 'text #:exists 'replace))
       (define-values (sub in out err) (subprocess to #f 'stdout md5 "-q" infile))
       (subprocess-wait sub)
       (custodian-shutdown-all (current-custodian))
       (subprocess-status sub)))))

;; Print (delete) every file in DIR containing the string "bin/sh":
;;
;; !!! BUGGY !!!
;; with script in the same directory as files it'll be deleted too
;;
;; (with-cwd dir
;;           (for-each (lambda (file)
;;                       (if (zero? (run (grep -s bin/sh ,file)))
;;                           (println file)))
;;                     (directory-files)))
;; --------------------------------------------------------------

;; `fold-files' version
(define rm-bin/sh-script1
  (make-script
   "Print (delete) every file in DIR containing the string  bin/sh"

   (begin
     (define (on-fold path type cum)
       (case type
         ((file) (if  (system (format "grep -s bin/sh ~a" path))
                      (values (cons (path->string path) cum) #f)
                      (values cum #f)))
         (else (values cum #f))))

     (fold-files on-fold '() #f #f))))

;; `for' version
(define rm-bin/sh-script2
  (make-script
   "Print (delete) every file in DIR containing the string  bin/sh"

   (begin
     (for/list ((path (in-list (map path->string (directory-list))))
                #:when (and  (file-exists? path)
                             (system (format "grep -s bin/sh ~a" path))))
       path))))


;; find all .c files in the current directory
;; collect them in a list of strings
;; find . -name "*.c" -print
;; (run/strings (find "." -name *.c -print))
(define find*.c1
  (make-script
   "Find all .c files in the current directory.
Collect them in a list of strings."

   (begin
     (for/list ((path (in-list (map path->string (directory-list))))
                #:when (regexp-match #rx".*\\.c$" path))
       path))))

(define find*.c2
  (make-script
   "Find all .c files in the current directory.
Collect them in a list of strings."

   (begin
     (define-values (in out) (make-pipe))
     (parameterize ((current-output-port out))
       (system (format "find . ~a ~a" "-name \"*.c\"" "-print"))
       (close-output-port out)
       (port->lines in)))))


;; find all directories in the current directory
;; collect them in a list
;; (filter (lambda (fname)
;;           (eq? 'directory
;;                (fileinfo:type (file-attributes fname))))
;;         (directory-files))

;; with helper-functions thrown in becomes as short as
;; (filter file-directory? (directory-files))

;; First-class procedures also allow iterators such as
;; for-each and filter to loop over lists of data
;; ---------------------------------------------------
;; build the list of all my files in /usr/tmp
;; (filter (lambda (f) (= (file-owner f) (user-uid)))
;;         (glob "/usr/tmp/*"))

;; ---------------------------------------------------
;; delete every C file in my directory
;; (for-each delete-file (glob "*.c"))

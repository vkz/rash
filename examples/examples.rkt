#lang racket

(define-syntax-rule (run-command body)
  (begin
    body))

(define-syntax-rule (command shell-version body)
  (begin
    (printf "~a\n" shell-version)
    (run-command body)))

;; (run (md5 -q README.md) (> README.md.md5))
(command
 "(run (md5 -q README.md) (> README.md.md5))"
 
 (begin
   (define md5 (find-executable-path "md5" #f))
   (define infile "README.md")
   (define outfile "README.md.md5")   
   (parameterize 
       ([current-custodian (make-custodian)])
     (current-subprocess-custodian-mode #f)
     (define to (open-output-file outfile #:mode 'text #:exists 'replace))
     (define-values (sub in out err) (subprocess #f to (current-output-port) md5 "-q" infile))
     (subprocess-wait sub)
     (custodian-shutdown-all (current-custodian))
     (subprocess-status sub)))

;; TODO
;; (1) (awk ...) deserves a separate section
;; (2) 

;; ====================
;; A Scheme Shell paper
;; ====================

;; compute md5 *fingerprint* or *message digest*
;; for README.md markdown file in your GutHub repo
;; output it to a README.md.md5
;; overwriting it if already exists
;; md5 -q README.md > README.md5
(run (md5 -q README.md) (> README.md.md5))


;; M4 preprocess each file in the current directory, then pipe
;; the input into cc. Errlog is foo.err, binary is foo.exe.
;; Run compiles in parallel.
;; m4 < foo.c | cc -o foo.exe -E - 2> foo.err
;; (for-each (lambda (file)
;;             (let ((outfile (replace-extension file ".exe"))
;;                   (errfile (replace-extension file ".err")))
;;               (& (| (m4) (cc -o ,outfile))
;;                  (< ,file)
;;                  (> 2 ,errfile))))
;;           (directory-files))


;; Delete every file in DIR containing the string "bin/sh":
(with-cwd dir
  (for-each (lambda (file)
              (if (zero? (run (grep -s bin/sh ,file)))
                  (delete-file file)))
            (directory-files)))


;; DES encrypt string PLAINTEXT with password KEY. My DES program
;; reads the input from fdes 0, and the key from fdes 3. We want to
;; collect the ciphertext into a string and return that, with error
;; messages going to our stderr. Notice we are redirecting Scheme data
;; structures (the strings PLAINTEXT and KEY) from our program into
;; the DES process, instead of redirecting from files. RUN/STRING is
;; like the RUN form, but it collects the output into a string and 
;; returns it (see following section).

;; (run/string (/usr/shivers/bin/des -e -3)
;;             (<< ,plaintext) (<< 3 ,key))


;; find all .c files in the current directory
;; collect them in a list of strings
;; find . -name "*.c" -print
(run/strings (find "." -name *.c -print))

;; find all directories in the current directory
;; collect them in a list
(filter (lambda (fname)
          (eq? 'directory 
               (fileinfo:type (file-attributes fname))))
        (directory-files))

;; with helper-functions thrown in becomes as short as
(filter file-directory? (directory-files))

;; First-class procedures also allow iterators such as
;; for-each and filter to loop over lists of data
;; --------------------------------------------------- 
;; build the list of all my files in /usr/tmp
(filter (lambda (f) (= (file-owner f) (user-uid)))
        (glob "/usr/tmp/*"))
;; --------------------------------------------------- 
;; delete every C file in my directory
(for-each delete-file (glob "*.c"))


;; ====================
;; Scsh.net examples
;; ====================

;; convert archive to tar format
;; good example but needs simplification
;; http://wcp.sdf-eu.org/software/cv2tar.scm

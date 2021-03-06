;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname TP_Projet) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #t #t none #f ())))
(define jeu-tableau '((* + + + + +)(* * + + * +)(+ * * + * +)(+ + + * * +)))

(define nb-line 4)
(define nb-col 6)

(define displayLine
  (lambda (liste)
    (if (null? (cdr liste)) (display (car liste))
        (begin (display (car liste)) (displayLine (cdr liste)))
        )))

(define displayBoard
  (lambda (liste)
    (if (null? (cdr liste))
        (displayLine (car liste))
        (begin (displayLine (car liste)) (newline) (displayBoard (cdr liste)))
        )))

(define ieme
  (lambda (x liste)
    (cond ((null? liste) liste)
          ((eq? x 1) (car liste))
          (else (ieme (- x 1) (cdr liste)))
          )))

(define alive?
  (lambda (i j liste)
    (cond ((or (< i 1) (< j 1) (> i nb-col) (> j nb-line)) #f)
          ((eq? (ieme i (ieme j liste)) '*) #t)
          ((eq? (ieme i (ieme j liste)) '+) #f)
          )))

(define nbvoisins
  (lambda (i j liste)
    (+ (if (alive? (- i 1) (- j 1) liste) 1 0)
       (if (alive? i (- j 1) liste) 1 0)
       (if (alive? (+ i 1) (- j 1) liste) 1 0)
       (if (alive? (- i 1) j liste) 1 0)
       (if (alive? (+ i 1) j liste) 1 0)
       (if (alive? (- i 1) (+ j 1) liste) 1 0)
       (if (alive? i (+ j 1) liste) 1 0)
       (if (alive? (+ i 1) (+ j 1) liste) 1 0))
    ))


(define voisinageL
  (lambda (j liste)
    (voisinageLbis 1 j liste)
    ))

(define voisinageLbis
  (lambda (i j liste)
    (if (or(< j 1) (> j nb-line)) '(hors de la grille)
        (cons (nbvoisins i j liste) (if (< i nb-col) (voisinageLbis (+ i 1) j liste) '()))
        )))

(define voisinagebis
  (lambda (x liste)
    (if (eq? x nb-line) (list(voisinageL x liste))
        (cons (voisinageL x liste) (voisinagebis (+ x 1) liste) )
        )))

(define voisinage
  (lambda (liste)
    (voisinagebis 1 liste)
    ))

(define nextStateL
  (lambda (j liste)
    (nextStateLbis 1 j liste)
    ))

(define nextStateLbis
  (lambda (i j liste)
    (if (null? (ieme (+ i 1) (voisinageL j liste)))
        (list(cond ((and (alive? i j liste) (or(< (ieme i (voisinageL j liste)) 2) (> (ieme i (voisinageL j liste)) 3))) 'D)
                   ((and (not (alive? i j liste))(eq? (ieme i (voisinageL j liste)) 3)) 'B)
                   (else (ieme i (ieme j liste)))))
        
        (cons (cond ((and (alive? i j liste) (or(< (ieme i (voisinageL j liste)) 2) (> (ieme i (voisinageL j liste)) 3))) 'D)
                    ((and (not (alive? i j liste))(eq? (ieme i (voisinageL j liste)) 3)) 'B)
                    (else (ieme i (ieme j liste)))) (nextStateLbis (+ i 1) j liste )))))



(define nextStatebis
  (lambda (j liste)
    (if (eq? j nb-line) (list(nextStateL j liste))
        (cons (nextStateL j liste) (nextStatebis (+ j 1) liste))
        )))

(define nextState
  (lambda (liste)
    (nextStatebis 1 liste)
    ))

(define updateCase
  (lambda (x)
    (cond ((eq? x 'B) '*)
          ((eq? x 'D) '+)
          (else x))
    ))

(define updateLine
  (lambda (liste)
    (if (null? (cdr liste)) (list (updateCase (car liste)))
        (cons (updateCase (car liste)) (updateLine (cdr liste)))
        )))

(define updateBoard
  (lambda (liste)
    (if (null? (cdr liste)) (list (updateLine (car liste)))
        (cons (updateLine (car liste)) (updateBoard (cdr liste)))
        )))


(define Play
  (lambda (x y actuel precedant)
    (begin (display "Pas ") (display x) (newline)
           (displayBoard (updateBoard actuel)) (newline) (newline)
           (if (and(equal? actuel precedant) (not(eq? x 0))) (display "Grille n'évolue plus")
               (if (and (not(eq? y 0)) (eq? x y)) (display "Terminé")
                   (begin (display "Changement d'etat:\n")
                   (displayBoard (voisinage actuel))
                   (newline) (newline)
                   (displayBoard (nextState actuel))
                   (newline) (newline)
                   (Play (+ x 1) y (updateBoard (nextState actuel)) actuel)
                   ))))))


(define main
  (begin
    (display "Entrez nombre de pas: ")
    (Play 0 (read)  jeu-tableau jeu-tableau)
    ))


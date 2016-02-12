#lang s-exp rosette
; geometric things in Wallingford/Rosette (also an example of handling state and change)
(require racket/gui/base)
(require "../core/wallingford.rkt")

(provide point point? point-x point-y make-point point-plus point-minus point-scale
         line line? line-end1 line-end2 make-line 
         circle circle? circle-center circle-radius make-circle contains-point
         color circle-color
         midpointline-line midpointline-midpoint make-midpointline make-midpointline-with-stays
         showthing)

; define color as a Rosette enum, so that we can put constraints on colors
; the elements are strings rather than symbols since the Racket graphics library wants strings to look up color names
(define-enum color '("red" "green" "blue" "black"))

;; structs for geometric objects (including colored objects)
(struct point (x y) #:transparent)
(struct line (end1 end2) #:transparent)
(struct circle (center radius color) #:transparent)
; (struct colored-circle circle (color) #:transparent)
(struct midpointline (line midpoint) #:transparent)

; functions to make symbolic objects
(define (make-point)
  (define-symbolic* x y number?)
  (point x y))
(define (make-line)
  (line (make-point) (make-point)))

; make-circle includes default values (if this works OK, add this to other functions as well)
(define (make-circle [initial-value (circle (point 150 150) 50 (color "blue"))])
  (define-symbolic* r number?)
  (define-symbolic* c color?)
  (define circ (circle (make-point) r c))
  ; give it a default value
  (assert (equal? circ initial-value))
  (stay (circle-radius circ))
  (stay (circle-center circ))
  (stay (circle-color circ))
  (wally-solve)
  circ)

(define (make-midpointline)
  (define line1 (make-line))
  (define midpoint (make-point))
  (always (equal? midpoint (point-scale (point-plus (line-end1 line1) (line-end2 line1)) 0.5)))
  (midpointline line1 midpoint))

(define (make-midpointline-with-stays)
  (define line1 (make-line))
  (define midpoint (make-point))
  ; the midpoint constraint and stays on the endpoints of the line
  ; We want to put the stays on the two endpoints of the line rather than the line as a whole, so 
  ; that we prefer solutions that leave one endpoint where it was even if we need to move the other.
  ; And we don't put the stays all the way down on the x and y values, to avoid the split stay problem.
  (always (equal? midpoint (point-scale (point-plus (line-end1 line1) (line-end2 line1)) 0.5)))
  (stay (line-end1 line1) #:priority low)
  (stay (line-end2 line1) #:priority low)
  ; we could put a stay on the midpoint but it's not actually needed
  (midpointline line1 midpoint))

; show function for all geometric types (oh for objects!!)
; unfortunately though objects aren't lifted in Rosette, so for now they remain structs
(define (showthing g dc)
  (cond [(point? g) (send dc draw-ellipse (point-x g) (point-y g) 5 5)]
        [(line? g) (send dc draw-line (point-x (line-end1 g)) (point-y (line-end1 g))
                         (point-x (line-end2 g)) (point-y (line-end2 g)))]
        [(circle? g) (send dc set-brush (make-object color% (label (circle-color g))) 'solid)
                     ; (send dc set-pen (make-object color% "blue") 2 'solid)
                     ; (printf "color ~a \n" (label (colored-circle-color g)))
                     (send dc set-pen (make-object color% (label (circle-color g))) 2 'solid)
                     (send dc draw-ellipse
                           (- (point-x (circle-center g)) (circle-radius g))
                           (- (point-y (circle-center g)) (circle-radius g))
                           (* 2 (circle-radius g)) (* 2 (circle-radius g)))]
;        [(circle? g) (send dc draw-ellipse
;                           (- (point-x (circle-center g)) (circle-radius g))
;                           (- (point-y (circle-center g)) (circle-radius g))
;                           (* 2 (circle-radius g)) (* 2 (circle-radius g)))]
        [(midpointline? g) (showthing (midpointline-line g) dc) (showthing (midpointline-midpoint g) dc)]
        ; compound graphical things are represented as lists.  The first thing should be on top,
        ; so reverse the list to show
        [(null? g) #t]
        [(pair? g) (for ([thing (reverse g)]) (showthing thing dc))]
        [(box? g) (showthing (unbox g) dc)]
        [else (error "unknown type of thing to show" g)]))

(define (contains-point thing pt)
  (cond [(circle? thing)
         (let ([x (- (point-x (circle-center thing)) (point-x pt))]
               [y (- (point-y (circle-center thing)) (point-y pt))]
               [r (circle-radius thing)])
           (<= (+ (* x x) (* y y)) (* r r)))]))

;; utility functions to operate on points
(define (point-plus p1 p2)
  (point (+ (point-x p1) (point-x p2)) (+ (point-y p1) (point-y p2))))
(define (point-minus p1 p2)
  (point (- (point-x p1) (point-x p2)) (- (point-y p1) (point-y p2))))
(define (point-scale p1 s)
  (point (* (point-x p1) s) (* (point-y p1) s)))
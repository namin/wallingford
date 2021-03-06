#lang racket
;; run all unit tests for wallingford

(require rosette/lib/roseunit)

(run-all-tests
 "wallingford-core-tests.rkt"
 "always-dynamic-tests.rkt"
 "geothings-tests.rkt"
 "electrical-things-tests.rkt"
 "electrical-things-dynamic-tests.rkt"
 "reactive-thing-tests.rkt"
 "sampling-tests.rkt"
 "mouse-tests.rkt"
 "when-tests.rkt"
 "while-tests.rkt"
 "max-min-tests.rkt"
 "integral-preprocessor-tests.rkt"
 "integral-symbolic-tests.rkt"
 "integral-numeric-tests.rkt"
 "integral-bad-arg-tests.rkt"
 "integrals-and-events.rkt"
 "linearized-when-tests.rkt"
 "viewer-tests.rkt"
 "compiled-reactive-thing-tests.rkt"
 "compiled-when-tests.rkt"
 "compiled-while-tests.rkt"
 )

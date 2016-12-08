#lang typed/racket/base

(provide CPointer
         CPointer?
         free)

(require typed/racket/unsafe)

(unsafe-require/typed ffi/unsafe
  (#:opaque CPointer cpointer?))

(require/typed ffi/unsafe
  (free (-> CPointer Void)))

(define CPointer? (make-predicate CPointer))

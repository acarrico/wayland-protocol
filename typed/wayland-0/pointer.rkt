#lang typed/racket/base

(provide Pointer
         Pointer?
         free)

(require typed/racket/unsafe)

(unsafe-require/typed ffi/unsafe
  (#:opaque Pointer cpointer?))

(require/typed ffi/unsafe
  (free (-> Pointer Void)))

(define Pointer? (make-predicate Pointer))

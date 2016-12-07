#lang typed/racket/base

(provide (struct-out errno)
         Errno
         get-errno)

(require/typed ffi/unsafe
  (saved-errno (-> Integer)))

(require/typed wayland-0/generated/libc
  (strerror (-> Integer String)))

(struct errno
  ((errno : Integer)
   (errstr : String))
  #:type-name Errno
  #:transparent)

(: get-errno (-> Errno))
(define (get-errno)
  (define e (saved-errno))
  (errno e (strerror e)))

#lang typed/racket/base

(provide (struct-out Errno)
         get-Errno)

(require/typed ffi/unsafe
  (saved-errno (-> Integer)))

(require/typed wayland-0/generated/libc
  (strerror (-> Integer String)))

(struct Errno
  ((errno : Integer)
   (errstr : String))
  #:transparent)

(: get-Errno (-> Errno))
(define (get-Errno)
  (define e (saved-errno))
  (Errno e (strerror e)))

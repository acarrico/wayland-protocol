#lang typed/racket/base

(provide UInt32
         Errno
         get-Errno
         (struct-out ErrorProxyHasListener)
         Pointer
         Pointer?
         saved-errno
         free
         strerror
         Interface
         Proxy
         Version)

(define-type UInt32 Exact-Nonnegative-Integer)

(define-type Version UInt32)

(require typed/racket/unsafe)

(unsafe-require/typed "../../wayland-0/util.rkt"
  (#:opaque Interface wl_interface?))

(unsafe-require/typed "../../wayland-0/client.rkt"
  (#:opaque Proxy wl_proxy?))

(unsafe-require/typed ffi/unsafe
  (#:opaque Pointer cpointer?))

(define Pointer? (make-predicate Pointer))

(require/typed ffi/unsafe
  (saved-errno (-> Integer))
  (free (-> Pointer Void)))

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

(struct ErrorProxyHasListener () #:transparent)

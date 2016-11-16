#lang typed/racket/base

(provide Errno
         get-Errno
         (struct-out ErrorProxyHasListener)
         Pointer
         Pointer?
         saved-errno
         free
         strerror
         upcast-DisplayPointer
         DisplayPointer
         RegistryPointer)

(require typed/racket/unsafe)

(unsafe-require/typed "../../wayland-0/generated/wl_display-client.rkt"
  (#:opaque DisplayPointer wl_display?))

(unsafe-require/typed "../../wayland-0/generated/wl_registry-client.rkt"
  (#:opaque RegistryPointer wl_registry?))

(unsafe-require/typed ffi/unsafe
  (#:opaque Pointer cpointer?))

(define Pointer? (make-predicate Pointer))

(require/typed ffi/unsafe
  (saved-errno (-> Integer))
  (free (-> Pointer Void)))

(require/typed wayland-0/generated/libc
  (strerror (-> Integer String)))

(module upcast racket/base
  (provide upcast-DisplayPointer)
  (require ffi/unsafe)
  (require wayland-0/generated/wl_display-client)
  
  (define (upcast-DisplayPointer d)
    (cast d _pointer _wl_display-pointer)))

(require/typed 'upcast
  (upcast-DisplayPointer (-> Pointer DisplayPointer)))

(struct Errno
  ((errno : Integer)
   (errstr : String))
  #:transparent)

(: get-Errno (-> Errno))
(define (get-Errno)
  (define e (saved-errno))
  (Errno e (strerror e)))

(struct ErrorProxyHasListener () #:transparent)

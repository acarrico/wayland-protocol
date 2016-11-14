#lang typed/racket/base

(provide Pointer
         saved-errno
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

(require/typed ffi/unsafe
  (saved-errno (-> Integer)))

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

#lang typed/racket/base

(provide CallbackPointer
         CallbackPointer?)

(require typed/racket/unsafe)

(unsafe-require/typed "../../wayland-0/generated/wl_callback-client.rkt"
  (#:opaque CallbackPointer wl_callback?))

(define CallbackPointer? (make-predicate CallbackPointer))

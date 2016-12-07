#lang typed/racket/base

(provide UInt32
         Int32
         (struct-out error-proxy-has-handlers)
         ErrorProxyHasHandlers
         Interface
         Proxy
         Version)

(require "errno.rkt")
(provide (all-from-out "errno.rkt"))

(require "pointer.rkt")
(provide (all-from-out "pointer.rkt"))

(define-type UInt32 Exact-Nonnegative-Integer)
(define-type Int32 Integer)

(define-type Version UInt32)

(require typed/racket/unsafe)

(unsafe-require/typed "../../wayland-0/util.rkt"
  (#:opaque Interface wl_interface?))

(unsafe-require/typed "../../wayland-0/client.rkt"
  (#:opaque Proxy wl_proxy?))

(struct error-proxy-has-handlers ()
  #:type-name ErrorProxyHasHandlers
  #:transparent)

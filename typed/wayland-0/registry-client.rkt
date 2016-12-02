#lang typed/racket/base

(provide RegistryListener
         registry-listener?
         RegistryHandleGlobal
         RegistryHandleGlobalRemove
         Registry
         registry?

         registry-add-listener
         registry-get-listener
         registry-destroy
         registry-bind)

(require typed/racket/unsafe
         racket/match)

(require "common.rkt")
(require "generated/wl_registry-client.rkt")

(require/typed "../../wayland-0/generated/wl_registry-client.rkt"
  (wl_registry-add-listener (-> Registry RegistryListener Pointer Integer))
  )

(: registry-add-listener
   (-> Registry RegistryHandleGlobal RegistryHandleGlobalRemove Pointer
       ;; NOTE: We return pointer for memory management.
       (U RegistryListener
          ErrorProxyHasListener)))
(define (registry-add-listener rp g gr p)
  (define listener (registry-listener g gr))
  (define result (wl_registry-add-listener rp listener p))
  (match result
    (0 listener)
    (-1
     (free (cast listener Pointer))
     (ErrorProxyHasListener))))

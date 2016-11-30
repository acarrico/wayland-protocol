#lang typed/racket/base

(provide RegistryListener
         RegistryListener?
         RegistryHandleGlobal
         RegistryHandleGlobalRemove
         Registry
         Registry?

         registry-add-listener
         registry-get-listener
         registry-destroy
         registry-bind)

(require typed/racket/unsafe
         racket/match)

(require "common.rkt")
(require "generated/wl_registry-client.rkt")

(define-type Name Integer)
(define-type Interface String)
(define-type Version Integer)

;; (_fun _pointer _wl_registry-pointer _uint32 _string/utf-8 _uint32 -> _void))
(define-type RegistryHandleGlobal (-> Pointer Registry Name Interface Version Void))

;; (global_remove (_fun _pointer _wl_registry-pointer _uint32 -> _void)))
(define-type RegistryHandleGlobalRemove (-> Pointer Registry Name Void))

(require/typed "../../wayland-0/generated/wl_registry-client.rkt"
  ;; ISSUE: importing c structs doesn't seem to work:
  ;; (#:struct wl_registry_listener ((global : HandleGlobal) (global_remove : HandleGlobalRemove))
  (make-wl_registry_listener (-> RegistryHandleGlobal
                                 RegistryHandleGlobalRemove
                                 RegistryListener))
  (wl_registry-add-listener (-> Registry RegistryListener Pointer Integer))
  ((wl_registry-get-listener registry-get-listener)
   (-> Registry (Option RegistryListener)))
  ((wl_registry-destroy registry-destroy) (-> Registry Void))
  )

(: registry-add-listener
   (-> Registry RegistryHandleGlobal RegistryHandleGlobalRemove Pointer
       ;; NOTE: We return pointer for memory management.
       (U RegistryListener
          ErrorProxyHasListener)))
(define (registry-add-listener rp g gr p)
  (define listener (make-wl_registry_listener g gr))
  (define result (wl_registry-add-listener rp listener p))
  (match result
    (0 listener)
    (-1 (ErrorProxyHasListener))))

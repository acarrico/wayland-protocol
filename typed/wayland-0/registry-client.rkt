#lang typed/racket/base

(provide RegistryHandleGlobal
         RegistryHandleGlobalRemove
         RegistryPointer
         RegistryPointer?
         registry-add-listener)

(require typed/racket/unsafe
         racket/match)

(require "common.rkt")

(define RegistryPointer? (make-predicate RegistryPointer))

(unsafe-require/typed "../../wayland-0/generated/wl_registry-client.rkt"
  (#:opaque RegistryListener wl_registry_listener?))

(define-type Name Integer)
(define-type Interface String)
(define-type Version Integer)

;; (_fun _pointer _wl_registry-pointer _uint32 _string/utf-8 _uint32 -> _void))
(define-type RegistryHandleGlobal (-> Pointer RegistryPointer Name Interface Version Void))

;; (global_remove (_fun _pointer _wl_registry-pointer _uint32 -> _void)))
(define-type RegistryHandleGlobalRemove (-> Pointer RegistryPointer Name Void))

(require/typed "../../wayland-0/generated/wl_registry-client.rkt"
  ;; ISSUE: importing c structs doesn't seem to work:
  ;; (#:struct wl_registry_listener ((global : HandleGlobal) (global_remove : HandleGlobalRemove))
  (make-wl_registry_listener (-> RegistryHandleGlobal
                                 RegistryHandleGlobalRemove
                                 RegistryListener))
  (wl_registry-add-listener (-> RegistryPointer RegistryListener Pointer Integer)))

(: registry-add-listener
   (-> RegistryPointer RegistryHandleGlobal RegistryHandleGlobalRemove Pointer
       ;; NOTE: We return pointer for memory management.
       (U Pointer
          ErrorProxyHasListener)))
(define (registry-add-listener rp g gr p)
  (define rl (make-wl_registry_listener g gr))
  (define result (wl_registry-add-listener rp rl p))
  (match result
    (0 (cast rl Pointer))
    (-1 (ErrorProxyHasListener))))

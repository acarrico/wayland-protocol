#lang typed/racket/base

(provide CallbackPointer
         CallbackPointer?
         CallbackDone
         callback-add-listener
         callback-destroy)

(require typed/racket/unsafe
         racket/match
         "common.rkt")

(unsafe-require/typed "../../wayland-0/generated/wl_callback-client.rkt"
  (#:opaque CallbackPointer wl_callback?))

(define CallbackPointer? (make-predicate CallbackPointer))

(unsafe-require/typed "../../wayland-0/generated/wl_callback-client.rkt"
  (#:opaque CallbackListener wl_callback_listener?))

;; (_fun _pointer _wl_callback-pointer _uint32 -> _void)
(define-type CallbackDone (-> Pointer CallbackPointer UInt32 Void))

(require/typed "../../wayland-0/generated/wl_callback-client.rkt"
  ;; ISSUE: importing c structs doesn't seem to work:
  ;; (#:struct wl_registry_listener ((global : HandleGlobal) (global_remove : HandleGlobalRemove))
  (make-wl_callback_listener (-> CallbackDone
                                 CallbackListener))
  (wl_callback-add-listener (-> CallbackPointer CallbackListener Pointer Integer))
  ((wl_callback-destroy callback-destroy) (-> CallbackPointer Void)))

(: callback-add-listener
   (-> CallbackPointer CallbackDone Pointer
       ;; NOTE: We return pointer for memory management.
       (U Pointer
          ErrorProxyHasListener)))
(define (callback-add-listener cbp done data)
  (define listener (make-wl_callback_listener done))
  (define result (wl_callback-add-listener cbp listener data))
  (match result
    (0 (cast listener Pointer))
    (-1 (ErrorProxyHasListener))))

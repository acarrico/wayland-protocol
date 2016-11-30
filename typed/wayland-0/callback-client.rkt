#lang typed/racket/base

(provide Callback
         Callback?
         CallbackListener
         CallbackListener?
         CallbackDone
         callback-add-listener
         callback-get-listener
         callback-destroy)

(require typed/racket/unsafe
         racket/match
         "common.rkt"
         "generated/wl_callback-client.rkt")

;; (_fun _pointer _wl_callback-pointer _uint32 -> _void)
(define-type CallbackDone (-> Pointer Callback UInt32 Void))

(require/typed "../../wayland-0/generated/wl_callback-client.rkt"
  ;; ISSUE: importing c structs doesn't seem to work:
  ;; (#:struct wl_registry_listener ((global : HandleGlobal) (global_remove : HandleGlobalRemove))
  (make-wl_callback_listener (-> CallbackDone
                                 CallbackListener))
  (wl_callback-add-listener (-> Callback CallbackListener Pointer Integer))
  ((wl_callback-get-listener callback-get-listener)
   (-> Callback (Option CallbackListener)))
  ((wl_callback-destroy callback-destroy) (-> Callback Void)))

(: callback-add-listener
   (-> Callback CallbackDone Pointer
       (U CallbackListener ErrorProxyHasListener)))
(define (callback-add-listener cbp done data)
  (define listener (make-wl_callback_listener done))
  (define result (wl_callback-add-listener cbp listener data))
  (match result
    (0 listener)
    (-1 (ErrorProxyHasListener))))

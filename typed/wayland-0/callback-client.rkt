#lang typed/racket/base

(provide Callback
         callback?
         CallbackListener
         callback-listener?
         CallbackHandleDone
         callback-add-listener
         callback-get-listener
         callback-destroy)

(require typed/racket/unsafe
         racket/match
         "common.rkt"
         "generated/wl_callback-client.rkt")

(require/typed "../../wayland-0/generated/wl_callback-client.rkt"
  (wl_callback-add-listener (-> Callback CallbackListener Pointer Integer))
  ((wl_callback-get-listener callback-get-listener)
   (-> Callback (Option CallbackListener)))
  ((wl_callback-destroy callback-destroy) (-> Callback Void)))

(: callback-add-listener
   (-> Callback CallbackHandleDone Pointer
       (U CallbackListener ErrorProxyHasListener)))
(define (callback-add-listener cbp done data)
  (define listener (callback-listener done))
  (define result (wl_callback-add-listener cbp listener data))
  (match result
    (0 listener)
    (-1
     (free (cast listener Pointer))
     (ErrorProxyHasListener))))

#lang typed/racket/base

(provide wl_display_connect
         wl_display_disconnect
         wl_display_roundtrip)

(require "display-client.rkt")

(require/typed "../../wayland-0/client.rkt"
  (wl_display_connect (-> (U String #f) (U DisplayPointer #f)))
  (wl_display_disconnect (-> DisplayPointer Void))
  (wl_display_roundtrip (-> DisplayPointer Integer))
  )

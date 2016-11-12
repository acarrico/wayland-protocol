#lang typed/racket/base

(provide DisplayPointer
         wl_display_connect
         wl_display_disconnect
         wl_display_roundtrip
         wl_display-get_registry)

(require "common.rkt")

(require/typed "../../wayland-0/client.rkt"
  (wl_display_connect (-> (U String #f) (U DisplayPointer #f)))
  (wl_display_disconnect (-> DisplayPointer Void))
  (wl_display_roundtrip (-> DisplayPointer Integer))
  )

(require/typed "../../wayland-0/generated/wl_display-client.rkt"
  (wl_display-get_registry (-> DisplayPointer RegistryPointer))
  )


#lang typed/racket/base

(provide DisplayPointer
         wl_display-get_registry)

(require "common.rkt")

(require/typed "../../wayland-0/generated/wl_display-client.rkt"
  (wl_display-get_registry (-> DisplayPointer RegistryPointer))
  )

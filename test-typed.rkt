#lang typed/racket/base

(require typed/wayland-0/registry-client
         typed/wayland-0/display-client
         typed/wayland-0/common
         racket/function)

(: registry-handle-global RegistryHandleGlobal)
(define (registry-handle-global data registry id interface version)
  (printf "registry-handle-global: I got called!\n ~s ~s ~s ~s ~s\n"
          (upcast-DisplayPointer data) registry id interface version))

(: registry-handle-global-remove RegistryHandleGlobalRemove)
(define (registry-handle-global-remove data registry name)
  (printf "registry-handle-global-remove: I got called!\n"))

;; NOTE: this is never freed:
(define registry-listener
  (make-wl_registry_listener registry-handle-global registry-handle-global-remove))

(: register (-> DisplayPointer Void))
(define (register wl_display)
  (define wl_registry (wl_display-get_registry wl_display))
  (wl_registry-add-listener wl_registry registry-listener (cast wl_display Pointer))
  (wl_display_roundtrip wl_display)
  (void))

((compose1
  (curry for-DisplayPointer wl_display_disconnect)
  (curry for-DisplayPointer register))
 #f)

((compose1
  (curry for-DisplayPointer wl_display_disconnect)
  (curry for-DisplayPointer register))
 "wayland-0")

((compose1
  (curry for-DisplayPointer wl_display_disconnect)
  (curry for-DisplayPointer register))
 "wayland-1")

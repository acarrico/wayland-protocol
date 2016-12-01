#lang typed/racket/base

(provide Display
         Display?
         downcast-Display
         display-connect
         display-disconnect
         display-roundtrip
         display-sync
         display-get-registry)

(require racket/match
         "common.rkt"
         "generated/wl_display-client.rkt"
         )

(require/typed "../../wayland-0/client.rkt"
  (wl_display_connect (-> (U String #f) (U Display #f)))
  (wl_display_disconnect (-> Display Void))
  (wl_display_roundtrip (-> Display Integer))
  )

(require (only-in "generated/wl_callback-client.rkt" Callback))
(require (only-in "generated/wl_registry-client.rkt" Registry))

;; ISSUE: libwayland ignores the name if WAYLAND_SOCKET is set.
(: display-connect (-> (Option String) (U Display Errno)))
(define (display-connect name)
  (or (wl_display_connect name)
      (get-Errno)))

(: display-disconnect (-> Display Void))
(define display-disconnect wl_display_disconnect)

(: display-roundtrip (-> Display (U Integer Errno)))
(define (display-roundtrip dp)
  (define result (wl_display_roundtrip dp))
  (if (= result -1)
      (get-Errno)
      result))

#lang typed/racket/base

(provide display-connect
         display-disconnect
         display-roundtrip
         (all-from-out "generated/wl_display-client.rkt"))

(require "common.rkt"
         "generated/wl_display-client.rkt")

(require/typed "../../wayland-0/client.rkt"
  (wl_display_connect (-> (U String #f) (U Display #f)))
  (wl_display_disconnect (-> Display Void))
  (wl_display_roundtrip (-> Display Integer))
  )

;; ISSUE: libwayland ignores the name if WAYLAND_SOCKET is set.
(: display-connect (-> (Option String) (U Display Errno)))
(define (display-connect name)
  (or (wl_display_connect name)
      (get-Errno)))

(: display-disconnect (-> Display Void))
(define (display-disconnect d)
  ;; NOTE: no need to destroy the display listener because it is a
  ;; static structure in libwayland (wl_display_listener).
  (wl_display_disconnect d))

(: display-roundtrip (-> Display (U Integer Errno)))
(define (display-roundtrip dp)
  (define result (wl_display_roundtrip dp))
  (if (= result -1)
      (get-Errno)
      result))

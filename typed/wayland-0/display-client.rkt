#lang typed/racket/base

(provide DisplayPointer
         DisplayPointer?

         display-connect
         display-disconnect
         display-roundtrip
         display-sync
         display-get-registry

         wl_display_connect
         wl_display_disconnect
         wl_display_roundtrip
         wl_display-get_registry)

(require racket/match
         "common.rkt"
         )

(define DisplayPointer? (make-predicate DisplayPointer))

(require/typed "../../wayland-0/client.rkt"
  (wl_display_connect (-> (U String #f) (U DisplayPointer #f)))
  (wl_display_disconnect (-> DisplayPointer Void))
  (wl_display_roundtrip (-> DisplayPointer Integer))
  )

(require (only-in "callback-client.rkt" CallbackPointer))

(require/typed "../../wayland-0/generated/wl_display-client.rkt"
  (wl_display-sync (-> DisplayPointer (U CallbackPointer #f)))
  (wl_display-get_registry (-> DisplayPointer (U RegistryPointer #f))))

;; ISSUE: libwayland ignores the name if WAYLAND_SOCKET is set.
(: display-connect (-> (Option String) (U DisplayPointer Errno)))
(define (display-connect name)
  (or (wl_display_connect name)
      (get-Errno)))

(: display-disconnect (-> DisplayPointer Void))
(define display-disconnect wl_display_disconnect)

(: display-roundtrip (-> DisplayPointer (U Integer Errno)))
(define (display-roundtrip dp)
  (define result (wl_display_roundtrip dp))
  (if (= result -1)
      (get-Errno)
      result))

(: display-sync (-> DisplayPointer (U CallbackPointer Errno)))
(define (display-sync dp)
  (or (wl_display-sync dp)
      (get-Errno)))

(: display-get-registry (-> DisplayPointer (U RegistryPointer Errno)))
(define (display-get-registry dp)
  (or (wl_display-get_registry dp)
      (get-Errno)))

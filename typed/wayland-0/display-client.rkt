#lang typed/racket/base

(provide (struct-out DisplayDisconnected)
         (struct-out DisplayConnected)
         (struct-out DisplayErrorConnect)
         
         DisplayError
         DisplayError?

         Display
         Display?
         for-Display

         DisplayPointer
         for-DisplayPointer
         wl_display_connect
         wl_display_disconnect
         wl_display_roundtrip
         wl_display-get_registry)

(require racket/match
         "common.rkt"
         )

(require/typed "../../wayland-0/client.rkt"
  (wl_display_connect (-> (U String #f) (U DisplayPointer #f)))
  (wl_display_disconnect (-> DisplayPointer Void))
  (wl_display_roundtrip (-> DisplayPointer Integer))
  )

(require/typed "../../wayland-0/generated/wl_display-client.rkt"
  (wl_display-get_registry (-> DisplayPointer RegistryPointer))
  )

(struct DisplayDisconnected
  ((name : String))
  #:transparent)

(struct DisplayConnected
  ((name : String)
   (pointer : DisplayPointer))
  #:transparent)

(struct DisplayErrorConnect
  ((name : String)
   (errno : Errno))
  #:transparent)

(define-type DisplayError
  (U DisplayErrorConnect))

(define DisplayError? (make-predicate DisplayError))

(define-type Display
  (U
   #f ; Use the WAYLAND_DISPLAY env. var. if set, otherwise "wayland-0".
   String
   DisplayDisconnected
   DisplayError
   DisplayConnected))

(define Display? (make-predicate Display))

(: for-Display (-> (-> DisplayConnected Void) Display Display))
(define (for-Display proc disp)
  (match disp
    ((struct DisplayConnected _)
     (proc disp)
     disp)
    ((? DisplayError?)
     disp)
    ((struct DisplayDisconnected _)
     (for-Display proc (DisplayDisconnected-name disp)))
    ((? string?)
     (cond ((wl_display_connect disp) =>
            (lambda (pointer)
              (define display (DisplayConnected disp pointer))
              (proc display)
              display))
           (else
            (DisplayErrorConnect disp (get-Errno)))))
    (#f (for-Display proc (or (getenv "WAYLAND_DISPLAY") "wayland-0")))))

(: for-DisplayPointer (-> (-> DisplayPointer Void) Display Display))
(define (for-DisplayPointer proc d)
  (for-Display (compose proc DisplayConnected-pointer) d))

;; (: map-Display (All (a) (-> (-> DisplayConnected a) Display (Vector Display a))))


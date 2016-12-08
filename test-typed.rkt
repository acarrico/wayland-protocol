#lang typed/racket/base

(require typed/wayland-0/registry-client
         typed/wayland-0/display-client
         typed/wayland-0/callback-client
         typed/wayland-0/common
         racket/function
         racket/match
         racket/pretty)

(let ()
  (define disp
    (match (display-connect #f)
      ((? display? (var disp)) disp)
      ((var errno) (error "connect: " errno))))

  (define registry
    (match (display-get-registry disp)
      ((? registry? (var registry)) registry)
      ((var errno) (error "register: " errno))))

  (: globals (HashTable Integer Symbol))
  (define globals (make-hasheq))

  (: handle-global RegistryHandleGlobal)
  (define (handle-global data registry id interface version)
    (hash-set! globals id (string->symbol interface)))

  (: handle-global-remove RegistryHandleGlobalRemove)
  (define (handle-global-remove data registry id)
    (hash-remove! globals id))

  (when (error-proxy-has-handlers?
         (registry-set-handlers
          registry
          (registry-handlers handle-global handle-global-remove)
          (cast disp CPointer)))
    (error "registry already has handlers"))

  (display-roundtrip disp)
  (printf "globals:\n")
  (pretty-display globals)

  ;; A display sync request is handled by a one shot done event. Here,
  ;; handle-done uses callback-destroy for cleanup:
  (: handle-done CallbackHandleDone)
  (define (handle-done data callback event-serial)
    (printf "display sync done with event serial ~a\n" event-serial)
    (callback-destroy callback))

  ;; display sync
  (printf "display sync request\n")
  (when (error-proxy-has-handlers?
         (callback-set-handlers
          (match (display-sync disp)
            ((? callback? (var callback)) callback)
            ((var errno) (error "sync: " errno)))
          (callback-handlers handle-done)
          (cast disp CPointer)))
    (error "callback already has handlers"))

  (display-roundtrip disp)
  (registry-destroy registry)
  (display-disconnect disp))

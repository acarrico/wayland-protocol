#lang typed/racket/base

(require typed/wayland-0/registry-client
         typed/wayland-0/display-client
         typed/wayland-0/callback-client
         typed/wayland-0/descriptor-client
         typed/wayland-0/common
         racket/function
         racket/match
         racket/pretty)

(struct global ((name : UInt32)
                (interface-name : Symbol)
                (interface : Interface)
                (version : Version))
  #:type-name Global
  #:transparent)

(: make-global (-> UInt32 Symbol Version (Option Global)))
(define (make-global name interface-name version)
  (define desc (find-descriptor interface-name))
  (and desc (global name interface-name desc version)))

(let ()
  (define disp
    (match (display-connect #f)
      ((? display? (var disp)) disp)
      ((var errno) (error "connect: " errno))))

  (define registry
    (match (display-get-registry disp)
      ((? registry? (var registry)) registry)
      ((var errno) (error "register: " errno))))

  (: globals-by-name (HashTable Integer Global))
  (define globals-by-name (make-hasheq))

  (: globals-by-interface-name (HashTable Symbol (Listof Global)))
  (define globals-by-interface-name (make-hasheq))

  (: handle-global RegistryHandleGlobal)
  (define (handle-global data registry name interface version)
    (define interface-name (string->symbol interface))
    (define global (make-global name interface-name version))
    (when global
      (hash-set! globals-by-name name global)
      (define globals
        (hash-ref globals-by-interface-name interface-name (lambda () '())))
      (hash-set! globals-by-interface-name interface-name
                 (cons global globals))))

  (: handle-global-remove RegistryHandleGlobalRemove)
  (define (handle-global-remove data registry id)
    (define global (hash-ref globals-by-name id))
    (when global
      (hash-remove! globals-by-name id)
      (define globals
        (hash-ref globals-by-interface-name (global-interface-name global)))
      (hash-set! globals-by-interface-name (global-interface-name global) (remove global globals))))

  (when (error-proxy-has-handlers?
         (registry-set-handlers
          registry
          (registry-handlers handle-global handle-global-remove)
          (cast disp CPointer)))
    (error "registry already has handlers"))

  (display-roundtrip disp)
  (printf "globals:\n")
  (pretty-display globals-by-name)

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

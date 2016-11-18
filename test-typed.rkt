#lang typed/racket/base

(require typed/wayland-0/registry-client
         typed/wayland-0/display-client
         typed/wayland-0/callback-client
         typed/wayland-0/common
         racket/function
         racket/match
         racket/pretty)

(let ()
  (define dp (match (display-connect #f)
               ((? DisplayPointer? (var dp)) dp)
               ((var errno) (error "connect: " errno))))

  (define rp (match (display-get-registry dp)
               ((? RegistryPointer? (var rp)) rp)
               ((var errno) (error "register: " errno))))

  (: globals (HashTable Integer Symbol))
  (define globals (make-hasheq))

  (: handle-global RegistryHandleGlobal)
  (define (handle-global data registry id interface version)
    (hash-set! globals id (string->symbol interface)))

  (: handle-global-remove RegistryHandleGlobalRemove)
  (define (handle-global-remove data registry id)
    (hash-remove! globals id))

  (define rl (match (registry-add-listener
                     rp
                     handle-global
                     handle-global-remove
                     (cast dp Pointer))
               ((? ErrorProxyHasListener? (var e))
                (error "registry already has listener"))
               ((? RegistryListener? (var rl)) rl)))

  (display-roundtrip dp)
  (printf "globals:\n")
  (pretty-display globals)

  ;; A display sync request is handled by a one shot done event. Here,
  ;; handle-done uses callback-get-listener to locate its listener for
  ;; cleanup.
  (: handle-done CallbackDone)
  (define (handle-done data callback callback-data)
    (printf "display sync done event ~a\n" callback-data)
    (define listener (callback-get-listener callback))
    (callback-destroy callback)
    (when listener (free (cast listener Pointer))))

  ;; display sync
  (printf "display sync request\n")
  (callback-add-listener
   (match (display-sync dp)
     ((? CallbackPointer? (var callback)) callback)
     ((var errno) (error "sync: " errno)))
   handle-done
   (cast dp Pointer))

  (display-roundtrip dp)
  (display-disconnect dp)
  (free (cast rl Pointer))
  (registry-destroy rp))

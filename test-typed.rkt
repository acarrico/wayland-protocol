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

  (define free-me (match (registry-add-listener
                          rp
                          handle-global
                          handle-global-remove
                          (cast dp Pointer))
                    ((? Pointer? (var p)) p)
                    ((? ErrorProxyHasListener? (var e))
                     (error "registry already has listener"))))
  (display-roundtrip dp)
  (printf "globals:\n")
  (pretty-display globals)

  (define cbp (match (display-sync dp)
                ((? CallbackPointer? (var cbp)) cbp)
                ((var errno) (error "sync: " errno))))

  (: handle-done CallbackDone)
  (define (handle-done data callback callback-data)
    (printf "callback: done ~a\n" callback-data)
    (free free-me*)
    (callback-destroy callback))

  (: free-me* Pointer)
  (define free-me* (match (callback-add-listener
                           cbp
                           handle-done
                           (cast dp Pointer))
                     ((? Pointer? (var p)) p)
                     ((? ErrorProxyHasListener? (var e))
                      (error "callback already has listener"))))

  (display-roundtrip dp)

  (display-disconnect dp)
  (free free-me))

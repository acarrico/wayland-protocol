#lang racket/base

(provide (struct-out About)
         (struct-out Protocol)
         (struct-out Interface) Interface-name
         interface-new-interfaces
         (struct-out Message) Message-name
         message-new-interface
         (struct-out Request)
         (struct-out Event)
         (struct-out Enum)
         (struct-out Arg) Arg-name
         arg-new-id?
         arg-new-interface
         (struct-out Entry))

(require racket/list)

(struct About (what name summary description) #:transparent)

(struct Protocol (name interfaces) #:transparent)

(struct Interface (about version requests events enums) #:transparent)
(define (Interface-name i) (About-name (Interface-about i)))

;; The names of the interfaces of the new objects sent by this
;; interface.
;; (: interface-new-interfaces (-> Interface (Listof String)))
(define (interface-new-interfaces i)
  (remove-duplicates
   (for*/fold ((result '()))
              ((m (append (map Request-message (Interface-requests i))
                          (map Event-message (Interface-events i)))))
     (cond ((message-new-interface m) => (lambda (i) (cons i result)))
           (else result)))))

(struct Message (about destructor? since args) #:transparent)
(define (Message-name m) (About-name (Message-about m)))

;; If the Message sends a new object, which interface?
;; (: message-new-interface (-> Message (Option String)))
(define (message-new-interface m)
  (for/or ((arg (Message-args m)))
    (arg-new-interface arg)))

(struct Request (message) #:transparent)

(struct Event (message) #:transparent)

(struct Enum (about since entries) #:transparent)

(struct Arg (about type summary interface-name allow-null) #:transparent)
(define (Arg-name a) (About-name (Arg-about a)))

;; Does the Arg send a new object?
;; (: arg-new-id? (-> Arg bool))
(define (arg-new-id? a) (string=? (Arg-type a) "new_id"))

;; If the Arg sends a new object, which interface?
;; (: arg-new-interface (-> Arg (Option String))
(define (arg-new-interface a)
  (if (arg-new-id? a) (Arg-interface-name a) #f))

(struct Entry (about value summary since) #:transparent)

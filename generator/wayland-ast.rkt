#lang at-exp racket/base

(provide (struct-out About)
         (struct-out Protocol)
         (struct-out Interface) Interface-name
         interface-id
         interface-name->descriptor-name
         interface-descriptor-name
         interface-name->type
         interface-type-id
         interface-untyped-module
         interface-typed-module
         interface-name->option-type
         interface-name->ffi-type
         interface-ffi-type
         interface-name->ffi-pointer
         interface-ffi-pointer
         interface-name->ffi-pointer/null
         interface-ffi-pointer/null
         interface-name->untyped-client-module
         interface-untyped-client-module
         interface-name->typed-client-module
         interface-typed-client-module
         interface-new-interfaces
         interface-interfaces
         interface-has-destroy-message
         (struct-out Message) Message-name
         message-handler-type-id
         message-new-id-arg
         message-new-interface
         message-interfaces
         message-bind?
         (struct-out Request)
         (struct-out Event)
         (struct-out Enum)
         (struct-out Arg) Arg-name
         arg-new-id?
         arg-new-interface
         arg-interface
         arg-bind?
         arg-trtype
         (struct-out Entry))

(require "util.rkt"
         racket/list
         racket/match
         racket/format
         racket/string)

(struct About (what name summary description) #:transparent)

(struct Protocol (name interfaces) #:transparent)

(struct Interface (about version requests events enums) #:transparent)
(define (interface-name->descriptor-name s)
  (string->symbol (format "~a_interface" s)))
(define (interface-descriptor-name i)
  (interface-name->descriptor-name (Interface-name i)))

(define (Interface-name i) (About-name (Interface-about i)))
(define (interface-name->id s) (string-trim s "wl_" #:right? #f))
(define (interface-id i) (interface-name->id (Interface-name i)))
(define (interface-name->type s)
  (string->symbol (string-titlecase (interface-name->id s))))
(define (interface-type-id i)
  (interface-name->type (Interface-name i)))
(define (interface-untyped-module i server?)
  (string->symbol
   (format "wayland-0/generated/~a-~a"
           (Interface-name i)
           (server?->string server?))))
(define (interface-typed-module i server?)
  (string->symbol
   (format "typed/wayland-0/generated/~a-~a"
           (Interface-name i)
           (server?->string server?))))
(define (interface-name->option-type s)
  `(Option ,(interface-name->type s)))
(define (interface-name->ffi-type s)
  (format "_~a" s))
(define (interface-ffi-type i)
  (interface-name->ffi-type (Interface-name i)))
(define (interface-name->ffi-pointer s)
  (format "_~a-pointer" s))
(define (interface-ffi-pointer i)
  (interface-name->ffi-pointer (Interface-name i)))
(define (interface-name->ffi-pointer/null s)
  (format "_~a-pointer/null" s))
(define (interface-ffi-pointer/null i)
  (interface-name->ffi-pointer/null (Interface-name i)))

(define (interface-name->untyped-client-module name)
  (string->symbol (format "wayland-0/generated/~a-client" name)))
(define (interface-untyped-client-module i)
  (interface-name->untyped-client-module (Interface-name i)))

(define (interface-name->typed-client-module name)
  (string->symbol (format "typed/wayland-0/generated/~a-client" name)))
(define (interface-typed-client-module i)
  (interface-name->typed-client-module (Interface-name i)))

;; The names of the interfaces of the new objects sent by this
;; interface.
;; (: interface-new-interfaces (-> Interface (Listof String)))
(define (interface-new-interfaces i)
  (remove-duplicates
   (filter-map message-new-interface
               (append
                (map Request-message (Interface-requests i))
                (map Event-message (Interface-events i))))))

;; The names of the interfaces of the objects sent by this interface.
;; (: interface-interfaces (-> Interface (Listof String)))
(define (interface-interfaces i)
  (remove-duplicates
   (append-map message-interfaces
               (append (map Request-message (Interface-requests i))
                       (map Event-message (Interface-events i))))))

(define (interface-has-destroy-message i)
  (for/or ((m (map Request-message (Interface-requests i))))
    (string=? (Message-name m) "destroy")))

(struct Message (about destructor? since args) #:transparent)
(define (Message-name m) (About-name (Message-about m)))

(define (message-handler-type-id i m)
  (define message-name
    (string-replace
     (string-titlecase (string-replace (Message-name m) "_" " "))
     " " ""))
  (string->symbol @~a{@(interface-type-id i)Handle@|message-name|}))

;; Message's new-id arg, if any:
(define (message-new-id-arg m)
  (for/or ((a (Message-args m))) (and (arg-new-id? a) a)))

;; If the Message sends a new object, which interface?
;; (: message-new-interface (-> Message (Option String)))
(define (message-new-interface m)
  (for/or ((arg (Message-args m)))
    (arg-new-interface arg)))

;; Which objects does the message send object?
;; (: message-interfaces (-> Message (Listof String)))
(define (message-interfaces m)
  (remove-duplicates
   (filter-map arg-interface (Message-args m))))

;; Does the message bind a new object? If so the sender will have to
;; give the interface and version.
(define (message-bind? m)
  (for/or ((arg (Message-args m)))
    (arg-bind? arg)))

(struct Request (message) #:transparent)

(struct Event (message) #:transparent)

(struct Enum (about since entries) #:transparent)

(struct Arg (about type summary interface-name allow-null) #:transparent)
(define (Arg-name a) (About-name (Arg-about a)))

;; Does the Arg send a new object?
;; (: arg-new-id? (-> Arg bool))
(define (arg-new-id? a) (string=? (Arg-type a) "new_id"))

;; Does the Arg send a object?
;; (: arg-object? (-> Arg bool))
(define (arg-object? a)
  (or (string=? (Arg-type a) "new_id")
      (string=? (Arg-type a) "object")))

;; If the Arg sends a new object, which interface?
;; (: arg-new-interface (-> Arg (Option String))
(define (arg-new-interface a)
  (if (arg-new-id? a) (Arg-interface-name a) #f))

;; If the Arg sends an object, which interface?
;; (: arg-interface (-> Arg (Option String))
(define (arg-interface a)
  (if (arg-object? a) (Arg-interface-name a) #f))

;; Does the arg bind a new object? If so the sender will have to give
;; the interface and version.
(define (arg-bind? a)
  (and (arg-new-id? a) (not (Arg-interface-name a))))

;; NOTE: trtype == Typed Racket type, vs. Arg-type above
(define (arg-trtype a)
  (match (Arg-type a)
    ("int" 'Int32)
    ("uint" 'UInt32)
    ("fixed" 'Fixed)
    ("string" 'String)
    ("array" 'WlArray)
    ("fd" 'FileDescriptor)
    ((or "new_id" "object")
     (define interface-name (Arg-interface-name a))
     (if interface-name
         (interface-name->type interface-name)
         'Pointer))))

(struct Entry (about value summary since) #:transparent)

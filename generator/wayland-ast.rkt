#lang racket/base

(provide (struct-out About)
         (struct-out Protocol)
         (struct-out Interface)
         (struct-out Message) Message-name
         (struct-out Request)
         (struct-out Event)
         (struct-out Enum)
         (struct-out Arg) Arg-name
         (struct-out Entry))

(struct About (what name summary description) #:transparent)

(struct Protocol (name interfaces) #:transparent)

(struct Interface (about version requests events enums) #:transparent)

(struct Message (about destructor? since args) #:transparent)
(define (Message-name m) (About-name (Message-about m)))

(struct Request (message) #:transparent)

(struct Event (message) #:transparent)

(struct Enum (about since entries) #:transparent)

(struct Arg (about type summary interface-name allow-null) #:transparent)
(define (Arg-name a) (About-name (Arg-about a)))

(struct Entry (about value summary since) #:transparent)

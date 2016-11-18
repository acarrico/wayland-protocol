#lang racket/base

(require racket/match)
(require "xml-util.rkt")
(require "wayland-ast.rkt")

(provide parse-wayland)

;; ISSUE: Assuming the XML is correct, for example not checking for
;; missing destructor, more than one new id argument, etc. But if C is
;; successfully generating code from the XML, this should too.

(define (parse-wayland pathname)
  (Protocol-parse
   (call-with-input-file pathname
     read-xml #:mode 'text)))

(define (About-parse what attrs content)
  (define name (find-attribute-value attrs 'name))
  (match content
    ((list (element _ _ 'description
                    (list-no-order (attribute _ _ 'summary summary))
                    desc-content)
           content* ...)
     (values (About what name summary (pcdata-content->string desc-content)) content*))
    (_
     (values (About what name #f #f) content))))

(define (Protocol-parse doc)
  (define-values (name doc-content)
    (match (cleanup (document-element doc))
      ((element _ _ 'protocol
                (list-no-order (attribute _ _ 'name name))
                content)
       (values name content))
      (_ (error "Protocol-parse: expected a protocol root element"))))

  (define-values (maybe-copyright more-elements)
    (maybe-element 'copyright doc-content))

  (define interface-elements
    (match more-elements
      ((list (and interfaces (element _ _ 'interface _ _)) ...)
       interfaces)
      (_ (error "Protocol-parse: expected interface elements"))))

  (Protocol name (map Interface-parse interface-elements)))

(define (Interface-parse elem)
  (define-values (attrs content) (parse-element elem 'interface))
  (define-values (about content*) (About-parse 'INTERFACE attrs content))
  (define-values (requests events enums)
    (for/fold ((requests '())
               (events '())
               (enums '()))
              ((elem content*))
      (match elem
        ((element _ _ 'request _ _)
         (values (cons (Request-parse elem) requests) events enums))
        ((element _ _ 'event _ _)
         (values requests (cons (Event-parse elem) events) enums))
        ((element _ _ 'enum _ _)
         (values requests events (cons (Enum-parse elem) enums)))
        (_ (error "Interface-parse: expected a request, event, or enum" elem)))))
  (Interface
   about
   (find-attribute-value attrs 'version)
   (reverse requests)
   (reverse events)
   (reverse enums)))

(define (Request-parse elem)
  (define-values (attrs content) (parse-element elem 'request))
  (define-values (about content*) (About-parse 'REQUEST attrs content))
  (define type? (maybe-find-attribute-value attrs 'type))
  (Request
   (Message about
            (and type? (equal? type? "destructor"))
            (string->number (or (maybe-find-attribute-value attrs 'since) "1"))
            (map Arg-parse content*))))

(define (Event-parse elem)
  (define-values (attrs content) (parse-element elem 'event))
  (define-values (about content*) (About-parse 'EVENT attrs content))
  (Event
   (Message about
            #f
            (string->number (or (maybe-find-attribute-value attrs 'since) "1"))
            (map Arg-parse content*))))

(define (Enum-parse elem)
  (define-values (attrs content) (parse-element elem 'enum))
  (define-values (about content*) (About-parse 'ENUM attrs content))
  (Enum about
        (maybe-find-attribute-value attrs 'since)
        (map parse-entry content*)))

(define (Arg-parse elem)
  (define-values (attrs content) (parse-element elem 'arg))
  (define-values (about content*) (About-parse 'ARG attrs content))
  (define allow-null (maybe-find-attribute-value attrs 'allow-null))
  (Arg about
       (find-attribute-value attrs 'type)
       (maybe-find-attribute-value attrs 'summary)
       (maybe-find-attribute-value attrs 'interface)
       (and allow-null (equal? "allow-null" "true"))))

(define (parse-entry elem)
  (define-values (attrs content) (parse-element elem 'entry))
  (define-values (about content*) (About-parse 'ENTRY attrs content))
  (Entry about
         (convert-attr-value (find-attribute-value attrs 'value))
         (maybe-find-attribute-value attrs 'summary)
         (maybe-find-attribute-value attrs 'since)))

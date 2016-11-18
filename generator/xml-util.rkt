#lang racket/base
(require xml)
(require racket/match)

(provide (all-from-out xml)
         cleanup
         pcdata-content->string
         parse-element
         maybe-element
         find-attribute-value
         maybe-find-attribute-value
         convert-attr-value)

(define cleanup (eliminate-whitespace '(copyright description) not))

(define (pcdata-content->string content)
  (apply string-append (map pcdata-string content)))

(define (parse-element elem name)
  (match elem
    ((element _ _ (? (lambda (x) (eq? name x))) attrs content)
     (values attrs content))
    (_ (error "parse-element: expected" name elem))))

(define (maybe-element name content)
  (match content
    ((list
      (and name-element (element _ _ (? (lambda (x) (eq? name x))) _ _))
      content ...)
     (values name-element content))
    (_
     (values #f content))))

(define (maybe-find-attribute-value attrs name)
  (match attrs
    ((list-no-order (attribute _ _ (? (lambda (x) (eq? name x))) val) _ ...)
     val)
    (_ #f)))

(define (find-attribute-value attrs name)
  (match attrs
    ((list-no-order (attribute _ _ (? (lambda (x) (eq? name x))) val) _ ...)
     val)
    (_ (error "find-attribute-value: missing attribute") attrs name)))

(define (convert-attr-value s)
  (match s
    ((regexp #px"0x([[:xdigit:]]+)" (list _ hex-digits))
     (string->symbol (string-append "#x" hex-digits)))
    ((regexp #px"[[:digit:]]+" (list digits))
     (string->symbol digits))
    (_
     (error "convert-attr-value: unrecognized syntax"))))

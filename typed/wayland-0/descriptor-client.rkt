#lang typed/racket/base

(provide find-descriptor)

(require "common.rkt"
         "generated/descriptor-table-client.rkt")

(: find-descriptor (-> Symbol (Option Interface)))
(define (find-descriptor sym)
  (cond ((assoc sym descriptor-table) => cdr)
        (else
         (printf "NOTE: find-descriptor: unrecognized interface: ~a\n" sym)
         #f)))

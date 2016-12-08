#lang racket

(provide server?->string)

(define (server?->string server?)
  (if server? "server" "client"))

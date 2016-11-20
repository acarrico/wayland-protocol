#lang racket/base

(require rackunit)
(require "wayland-ast.rkt")
(require "wayland-parser.rkt")
(require "../config.rkt")

(define wayland-protocol
  (parse-wayland
   (string-append wayland-share "wayland.xml")))

(define interfaces (Protocol-interfaces wayland-protocol))
(define wl_surface (findf (lambda (i)
                            (equal? "wl_surface" (Interface-name i)))
                          interfaces))

(check-not-false wl_surface)

(check-eq? (arg-interface (Arg #f "object" #f "wl_buffer" #t)) "wl_buffer")

(check-equal? (sort (interface-interfaces wl_surface) string<?)
              (sort '("wl_buffer" "wl_callback" "wl_region" "wl_output") string<?))

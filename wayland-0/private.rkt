#lang racket/base

;; stuff from wayland-private.h and connection.c

(require ffi/unsafe ffi/unsafe/define)

(require "util.rkt")

(define-cstruct _wl_object
  ((interface _wl_interface-pointer)
   (implementation _pointer)
   (id _uint32)))

(define _wl_connection-pointer (_cpointer 'wl_connection))
(define _wl_connection-pointer/null (_cpointer/null 'wl_connection))

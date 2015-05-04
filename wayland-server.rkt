#lang racket/base

(require ffi/unsafe ffi/unsafe/define)

(provide _wl_client-pointer
         _wl_resource-pointer)

(define _wl_client-pointer (_cpointer 'wl_client))
(define _wl_resource-pointer (_cpointer 'wl_resource))

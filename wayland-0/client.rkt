#lang racket/base

(require ffi/unsafe ffi/unsafe/define)

(provide
 _wl_proxy-pointer
 _wl_proxy-pointer/null
 wl_proxy?
 ;; _wl_client-pointer
 ;; _wl_resource-pointer
 wl_proxy_marshal_array
 wl_proxy_marshal_array_constructor
 wl_proxy_marshal_array_constructor_versioned
 wl_proxy_destroy
 wl_proxy_add_listener
 wl_proxy_get_listener
 wl_proxy_set_user_data
 wl_proxy_get_user_data
 wl_display_connect
 wl_display_disconnect
 wl_display_roundtrip)

(define _wl_client-pointer (_cpointer 'wl_client))
(define _wl_resource-pointer (_cpointer 'wl_resource))

(require "util.rkt")
(require "private.rkt")
(require "generated/libwayland-client.rkt"
         "generated/libc.rkt")

(define-ffi-definer define-wl-client libwayland-client)

(define _wl_proxy-pointer (_cpointer 'wl_proxy))
(define _wl_proxy-pointer/null (_cpointer/null 'wl_proxy))
(define (wl_proxy? x) (and (cpointer? x) (cpointer-has-tag? x 'wl_proxy)))

;; NOTE: these are also defined in generated/wl_display-client.rkt,
;; which requires this module, so we must also define them here:
(define _wl_display-pointer (_cpointer 'wl_display))
(define _wl_display-pointer/null (_cpointer/null 'wl_display))

(define-wl-client wl_proxy_marshal_array
  (_fun #:save-errno 'posix
        _wl_proxy-pointer
        _uint32
        _wl_argument-pointer
        -> _void))

(define-wl-client wl_proxy_marshal_array_constructor
  (_fun #:save-errno 'posix
        _wl_proxy-pointer
        _uint32
        _wl_argument-pointer
        _wl_interface-pointer
        -> _wl_proxy-pointer/null))

(define-wl-client wl_proxy_marshal_array_constructor_versioned
  (_fun #:save-errno 'posix
        _wl_proxy-pointer
        _uint32
        _wl_argument-pointer
        _wl_interface-pointer
        _uint32
        -> _wl_proxy-pointer/null))

(define-wl-client wl_proxy_destroy
  (_fun _wl_proxy-pointer
        -> _void))

(define-wl-client wl_proxy_add_listener
  (_fun _wl_proxy-pointer
        _pointer ;; actually it is declared void (**implementation)(void)
        _pointer
        -> _int))

(define-wl-client wl_proxy_get_listener
  (_fun _wl_proxy-pointer -> _pointer))

(define-wl-client wl_proxy_set_user_data
  (_fun _wl_proxy-pointer
        _pointer
        -> _void))

(define-wl-client wl_proxy_get_user_data
  (_fun _wl_proxy-pointer
        -> _pointer))

(define-wl-client wl_display_connect (_fun #:save-errno 'posix
                                           _string/utf-8
                                           -> _wl_display-pointer/null
                                           ))

(define-wl-client wl_display_disconnect (_fun _wl_display-pointer -> _void))

(define-wl-client wl_display_roundtrip (_fun _wl_display-pointer -> _int))

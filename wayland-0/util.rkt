#lang racket/base

(require ffi/unsafe ffi/unsafe/define)

(provide (struct-out wl_interface)
         _wl_interface
         _wl_interface-pointer
         (struct-out wl_array)
         _wl_array
         _wl_array-pointer
         _wl_fixed
         _wl_argument
         _wl_argument-pointer
         set-wl_argument-i!
         set-wl_argument-u!
         set-wl_argument-f!
         set-wl_argument-s!
         set-wl_argument-o!
         set-wl_argument-n!
         set-wl_argument-a!
         set-wl_argument-h!
         )

(define-cstruct _wl_message
  ((name _string/utf-8)
   (signature _string/utf-8)
   (types (_cpointer 'wl_interface))))

(define-cstruct _wl_interface
  ((name _string/utf-8)
   (version _int)
   (method_count _int)
   (methods _wl_message-pointer)
   (event_count _int)
   (events _wl_message-pointer)))

(define-cstruct _wl_array
  ((size _size)
   (alloc _size)
   (data _pointer)))

(define _wl_fixed _int32)

(define _wl_argument
  (_union _int32
          _uint32
          _wl_fixed
          _string/utf-8
          (_cpointer/null 'wl_object)
          _uint32
          _wl_array-pointer
          _int32))

(define _wl_argument-pointer (_cpointer 'wl_argument))

(define (set-wl_argument-i! a v)
  (union-set! a 0 v))

(define (set-wl_argument-u! a v)
  (union-set! a 1 v))

(define (set-wl_argument-f! a v)
  (union-set! a 2 v))

(define (set-wl_argument-s! a v)
  (union-set! a 3 v))

(define (set-wl_argument-o! a v)
  (union-set! a 4 v))

(define (set-wl_argument-n! a v)
  (union-set! a 5 v))

(define (set-wl_argument-a! a v)
  (union-set! a 6 v))

(define (set-wl_argument-h! a v)
  (union-set! a 7 v))

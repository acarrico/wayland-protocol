#lang racket/base

(provide wayland-share
         wayland-lib
         libc-dir)

(define wayland-share (or (getenv "wayland_share") "/usr/share/wayland/"))
(define wayland-lib (or (getenv "wayland_lib") ""))
(define libc-dir (or (getenv "libc_lib") ""))

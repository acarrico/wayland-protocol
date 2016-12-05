# wayland-protocol
Wayland display protocol in Racket

By Anthony Carrico <acarrico@memebeam.org>, this work is in the public
domain.

Among many possible approaches, I have chosen to bind to the C
libraries (insert rationale here), and to dump racket source code
(insert rationale here).

# Test or Development

The best way to get a usable environment for testing or development is
to install the nix package manager (https://nixos.org/nix/). Nix will
not pollute your machine's current Linux distribution.

`$ nix-shell`

Start an interactive shell based on 'default.nix':

This enters a working environment with racket, wayland, and weston.
There is no need to have any of these installed in your native user
environment.

`$ source dev.bash`

This sets up a useful environment for development. Feel free create
your own variant to suit your own taste. Here are some useful
functions provided by 'dev.bash':

`$ build`

This (re)builds the generated modules.

`$ weston-pixman`

This starts Weston with x11 backend and software rendering (useful if
the weston defaults are giving your machine trouble).

`$ racket test-typed.rkt`

See below.

`$ exit`

Leaving the interactive shell drops you back into your normal
user environment.

# What if I refuse to develop with nix, or have trouble?

* Examine 'default.nix' and 'dev.bash' for dependencies and
configuration. Install the dependencies and configure your development
environment. See also 'config.rkt'.

* The binding generator is cross-friendly in the sense that it doesn't
try to probe anything from the build machine.

* The nix configuration generates absolute foreign library pathnames
which are foolproof. If you take the default pathless relative
filenames, Racket may fail to find your Linux distribution's Wayland
libraries (I've seen it go both ways in various environments). In that
case, either build with the 'wayland-lib' environment variable set to
match your target, or run with Racket's foreign library search paths
set to match your target.

* If necessary, check which versions of Racket, Wayland, and Weston
were in the 'nixpkgs-unstable' channel around the time of the commit.

# Installation

There is currently no installable package for any system. The nix
derivation doesn't even install anything, it is currently just useful
for nix-shell.

# Test the typed/wayland-0 collection

I have a (very) simple test client which you can try:

```
$ racket test-typed.rkt
failed to connect to wayland display "No such file or directory"
  context...:
   wayland-protocol/test-typed.rkt: [running body]
```

If you get the "failed to connect" message, you probably aren't
running a server. Try starting weston (see 'weston-pixman' above):

```
$ racket test-typed.rkt
globals:
#hasheq((18 . weston_screenshooter)
        (17 . weston_desktop_shell)
        (16 . wl_shell)
        (15 . xdg_shell)
        (14 . zxdg_shell_v6)
        (13 . zwp_text_input_manager_v1)
        (12 . zwp_input_method_v1)
...
```

# Details typed/wayland-0 collection

See 'test-typed.rkt' for more details, error handling.

```
(define disp (display-connect #f)
(display-disconnect disp)
```

This is the basic connection to the display server.

```
(define registry (display-get-registry disp))

(: globals (HashTable Integer Symbol))
(define globals (make-hasheq))

(: handle-global RegistryHandleGlobal)
(define (handle-global data registry id interface version)
  (hash-set! globals id (string->symbol interface)))

(: handle-global-remove RegistryHandleGlobalRemove)
(define (handle-global-remove data registry id)
  (hash-remove! globals id))

(registry-set-handlers
  registry
  (registry-handlers handle-global handle-global-remove)
  (cast disp Pointer))

(display-roundtrip disp)
(registry-destroy registry)
```

Use the display to get the registry. The registry has handlers for
two events, *handle-global* and *handle-global-remove*. The server
will announce the globals once we flush the request and the events
through with *display-roundtrip*. This simple example (and necessary
first step) illustrates how to make requests and process events.

Note that handlers get a 'data' arguement, this reflects the mechanism
for simulating closure arguments with C procedures. I've needlessly
sent the display pointer as 'data', but our handlers are true
closures, so you can simply ignore this mechanism and close over any
values your handlers might need.

The example file also shows another interface, comprising a display
sync request and handling the done event on the corresponding callback
object.

Note: Don't confuse "callback" with the generic term "handler".
Callbacks sound very generic, but they are specific Wayland objects
which only handle the display sync; other events are handled by other
objects (in client side terminology).

Note: A "listener" is a C api mechanism for dispatching events to
handlers (in client side terminology). This collection does currently
use libwayland's listener mechanism, but it is hidden in the
typed/wayland-0 collection. In short, just set handlers on Wayland
objects and destroy the objects when you are done.

The API is documented at
https://wayland.freedesktop.org/docs/html/apa.html, and the types
defined in typed/wayland-0/generated are also informative.

# Code Generation

The generator is not the most beautiful code of all time, but I
believe it dumps similar to the C language generator. I've statically
generated racket code to initialize events, for some reason the C code
does this dynamically from strings of argument type codes.

The code generator dumps both client and server side Racket modules
for every Wayland interface present in the protocol's XML file. The
only generated documentation is some comments in the code (it doesn't
generate Scribble docs). This API is (currently) in the wayland-0
collection. There is a small example in test-client.rkt. It is not
recommended for direct use.

The wayland-0 collection is wrapped by the typed/wayland-0 collection.
There is a small example in test-typed.rkt. This is currently the
nicest API to use.

# Test the wayland-0 collection

You should probably ignore this lower level API whenever
typed/wayland-0 has what you need.


```
$ racket test-client.rkt
connected to wayland display #<cpointer:_wl_display>
got registry #<cpointer:_wl_registry>
registry-handle-global: I got called!
 #<cpointer> #<cpointer:_wl_registry> 1 "wl_compositor" 3
registry-handle-global: I got called!
 #<cpointer> #<cpointer:_wl_registry> 2 "wl_subcompositor" 1
registry-handle-global: I got called!
 #<cpointer> #<cpointer:_wl_registry> 3 "wl_scaler" 2
registry-handle-global: I got called!
...
```

# Details wayland-0 collection

You should probably ignore this lower level API whenever
typed/wayland-0 has what you need.

I started the project with "test-client.rkt" which was completely
manual ffi bindings, and from there created the wayland-0 and
wayland-0/generated modules. Let's walk the source.

```
(require "wayland-0/client")

(let ((wl-display (wl_display_connect #f)))
  ...
  (wl_display_disconnect wl-display))
```

This the basic connection to the display server.

```
(require ...
         wayland-0/generated/wl_display-client)
         wayland-0/generated/wl_registry-client
         ...)

(define (registry-handle-global data registry id interface version)
  (printf "registry-handle-global: I got called!\n ~s ~s ~s ~s ~s\n"
          data registry id interface version))

(define (registry-handle-global-remove data registry name)
  (printf "registry-handle-global-remove: I got called!\n"))

;; NOTE: this is never freed:
(define registry-listener
  (make-wl_registry_listener registry-handle-global registry-handle-global-remove))

(let ((wl-display (wl_display_connect #f)))
  ...
  (let ((wl-registry (wl_display-get_registry wl-display)))
    ...
    (wl_registry-add-listener wl-registry registry-listener wl-display)
    (wl_display_roundtrip wl-display))
  ...)
```

Use the display to get to the registry. The *registry-listener* has
handlers for two events, *registry-handle-global* and
*registry-handle-global-remove*. The server will announce the globals
once we flush the request and the events through with
*wl_display_roundtrip*. This simple example (and necessary first step)
illustrates how to make requests and process events.

# Further Testing

There are two modules wayland-0/generated/client-test and
wayland-0/generated/server-test which simply require all the
interfaces for one side or the other. The sever test currently reveals
some problems.

# Status

Server side is still very rough.

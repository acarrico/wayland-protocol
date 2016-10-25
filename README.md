# wayland-protocol
Wayland display protocol in Racket

By Anthony Carrico <acarrico@memebeam.org>, this work is in the public
domain.

This project is very far from polished. I'm uploading now because of a
request from someone in #racket on Freenode IRC who would like to play
with Wayland.

Among many possible approaches, I have chosen to bind to the C
libraries (insert rationale here), and to dump racket source code
(insert rationale here):

# Code Generation

This is not the most beautiful code of all time, but I believe it
dumps similar to the C language generator. I've statically generated
racket code to initialize events, for some reason the C code does this
dynamically from strings of argument type codes.

The code generator dumps both client and server side Racket modules
for every Wayland interface present in the protocol's XML file. The
only generated documentation is some comments in the code (it doesn't
generate Scribble docs).

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

This (re)builds the 'generated' tree.

`$ weston-pixman`

This starts Weston with x11 backend and software rendering (useful if
the defaults are giving your machine trouble).

`$ racket test-client.rkt`

See below.

`$ exit`

Leaving the interactive shell drops you back into your normal
user environment.

# What if I refuse to develop with nix, or have trouble?

* Examine 'default.nix' and 'dev.bash' for dependencies and
configuration. Install the dependencies and configure your development
environment.

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

# Test Client

I have a (very) simple test client which you can try:

```
$ racket test-client.rkt
failed to connect to wayland display "No such file or directory"
  context...:
   /home/acarrico/src/wayland/racket/wayland-protocol/test-client.rkt: [running body]
```

If you get the "failed to connect" message, you probably aren't
running a server. Try starting weston (see 'weston-pixman' above):

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

Now you see the test client in operation.

# Details

I started the project with "test-client.rkt" which was completely
manual ffi bindings, and from there created "wayland-*.rkt", and the
generated interfaces. Let's walk the source.

```
(require "wayland-client.rkt")

(let ((wl-display (wl_display_connect #f)))
  ...
  (wl_display_disconnect wl-display))
```

This the basic connection to the display server.

```
(require ...
         "generated/wl_display-client.rkt")
         "generated/wl_registry-client.rkt")

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
callbacks for two events, *registry-handle-global* and
*registry-handle-global-remove*. The server will announce the globals
once we flush the request and the events through with
*wl_display_roundtrip*. This simple example (and necessary first step)
illustrates how to make requests and process events.

# Further Testing

In theory, with *(require "generated/wl_xxxxxxxx-client.rkt")* (or
*-server.rkt*) you can get busy with any interface in the Wayland
protocol. However, nothing else has been tested. In reality, the
generator and/or the "wayland-xxx.rkt" modules may need a little
tweaking.

There are two files "generated/client-test.rkt" and
"generated/server-test.rkt" which simply require all the interfaces
for one side or the other. Both these tests currently reveal some
problems, the server side definitely needs more work (my long term to
do list includes the item "wayland ffi server side bindings").

# Status

My current Racket activity is in the
[Bindings as Sets of Scopes](https://github.com/acarrico/evaluator)
project rather than this wayland-protocol project, but I'll get back
around to this one, and I'd love to hear from anyone who tries it.

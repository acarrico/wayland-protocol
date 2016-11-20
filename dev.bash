# these are just convenient in emacs *shell*:
alias git='git --no-pager'
export PAGER=cat

# Make the binaries available from the nix store:
export PATH=$racket/bin:$weston/bin:$PATH

# Configure the code generator:
export wayland_share=$wayland/share/wayland/
export wayland_lib=$wayland/lib/
export libc_lib=$libc/lib/

# Configure the racket runtime:
#
# export PLTADDONDIR=
#
# ISSUE: this installs in home.
raco pkg install
raco pkg install opengl

# To generate the racket wayland interface:
function build  () {
  if test ! -d wayland-0/generated; then
    mkdir wayland-0/generated
  fi
  racket gen-wayland-protocol.rkt
}

function raco-test () {
  raco test generator/test.rtk
}

function client-test () {
  racket wayland-0/generated/client-test.rkt
}

# To start weston with software rendering (if default backend is
# acting up):
function weston-pixman () {
  weston --backend=x11-backend.so --no-config --use-pixman &
}

# To try the test client:
function wayland-test () {
  racket test-client.rkt
}

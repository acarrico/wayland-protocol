# these are just convenient in emacs *shell*:
alias git='git --no-pager'
export PAGER=cat

# Make the binaries available from the nix store:
export PATH=$racket/bin:$weston/bin:$PATH

# Configure the code generator:
export wayland_share=$wayland/share/wayland/
export wayland_lib=$wayland/lib/

# To generate the racket wayland interface:
function build  () {
  if test ! -d generated; then
    mkdir generated
  fi
  racket gen-wayland-protocol.rkt
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

# these are just convenient in emacs *shell*:
alias git='git --no-pager'
export PAGER=cat

# Make the binaries available from the nix store:
export PATH=$racket/bin:$weston/bin:$PATH

# Generate the racket wayland interface:
export protocol=$wayland/share/wayland/wayland.xml
if test ! -d generated; then
    mkdir generated
fi
racket gen-wayland-protocol.rkt

# ISSUE: This weston has issues for me, so temporarily using software
# rendering:
weston --backend=x11-backend.so --no-config --use-pixman &

# After weston comes up, try the test client:
# racket test-client.rkt

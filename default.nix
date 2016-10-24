# NOTE: This doesn't create a usable derivation, but will drop you
# into a useful nix-shell for development.

let
  pkgs = import <nixpkgs> {};
in derivation {
  name="wayland-protocol-racket";
  builder="${pkgs.bash}/bin/bash";
  racket ="${pkgs.racket}";
  wayland ="${pkgs.wayland}";
  weston ="${pkgs.weston}";
  system = builtins.currentSystem;
}

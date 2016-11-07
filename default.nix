# NOTE: This doesn't create a usable derivation, but will drop you
# into a useful nix-shell for development.

let
  # pkgs = import <nixpkgs> {};
  pkgs = import ../nixpkgs {};
in derivation {
  name="wayland-protocol-racket";
  builder="${pkgs.bash}/bin/bash";
  racket ="${pkgs.racket-gl}";
  wayland ="${pkgs.wayland}";
  weston ="${pkgs.weston}";
  mesa ="${pkgs.mesa}";
  system = builtins.currentSystem;
}

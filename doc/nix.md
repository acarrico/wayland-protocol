# Learning nix

* Read the official docs.
* EXERCISE: Experiment with screwing things up and then 'nix-env --list-generation', 'nix-env --switch-generation' to fix.
* EXERCISE: Uninstall nix-env, and figure out how to fix it.
** HINT: search the /nix/store for bin/nix-env

# Setting up your environment

Currently these are my recommendations:

Rather than mutating your environment with nix-env, declare a
configuration in '~/.nixpkgs/config.nix'. Avoid adding things that are
specific to a project, use a local derivation for that purpose.

I am running Debian on my desktop and Arch linux on my laptop, but I
can keep things consistent with config.nix. Note that I have only
installed 'nix' and 'all':

```
$ nix-env -q
all
nix-1.11.4
```

'all' is a custom derivation for my local environment. Here in
'config.nix' you can see what 'all' entails:

```
{
  packageOverrides = pkgs_: with pkgs_; {
    all = with pkgs; buildEnv {
      name = "all";
      paths = [
        dmenu
        # ghc
        nix-repl
        # racket
        # rustc
        # stack
        xmonad-with-packages
        emacs
        mesa
        glxinfo
      ];
    };
  };
}
```

If I need to add something to this derivation, then install again:

```
$ nix-env -i all
replacing old ‘all’
installing ‘all’
```

Now my new environment is available.

# Writing derivations

* Do the excercises in the 'nix pills' series of blog posts: http://lethalman.blogspot.com/search/label/nixpills

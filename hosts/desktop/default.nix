{ config, pkgs, inputs, ... }:

import ./configuration.nix { inherit config pkgs inputs; }
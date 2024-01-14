#!/usr/bin/env bash

which home-manager ||\
nix shell home-manager

git add . &&\
sudo nixos-rebuild switch --show-trace --flake .#$1 &&\
home-manager switch --show-trace --flake .#$2

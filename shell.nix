# /qompassai/rtemplate/shell.nix
# -------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{ pkgs ? import <nixpkgs> {} }:

let
  fenix = import (fetchTarball "https://github.com/nix-community/fenix/archive/refs/heads/main.tar.gz") { inherit pkgs; };
in
pkgs.mkShell {
  buildInputs = [
    fenix.stable.toolchain
    fenix.beta.toolchain
    fenix.nightly.toolchain
    fenix.fromToolchainFile ./rust-toolchain.toml or fenix.stable.toolchain
    pkgs.cargo-zigbuild
    pkgs.cargo-cross
    pkgs.cbindgen
    pkgs.wasm-pack
    pkgs.just
    pkgs.sccache
    pkgs.bindgen
    pkgs.cxxbridge-cmd
    pkgs.zig
    pkgs.pkg-config
    pkgs.openssl
    pkgs.llvmPackages_16.llvm
  ];

  shellHook = ''
    echo "==> Rust multi-toolchain cross-compilation shell ready!"
    echo "Use e.g. 'cargo +nightly build' or 'cargo +stable build'."
  '';
}


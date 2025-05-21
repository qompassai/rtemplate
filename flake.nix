# ~/.GH/Qompass/Templates/rtemplate/flake.nix
# -------------------------------------------
# Copyright (C) 2025 Qompass AI, All rights reserved

{
  description = "Qompass AI: Multi-toolchain Rust cross-compilation devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    fenix.url = "github:nix-community/fenix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, fenix, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # List of toolchains you want available
        toolchains = [
          fenix.packages.${system}.stable
          fenix.packages.${system}.beta
          fenix.packages.${system}.nightly
          fenix.packages.${system}.nightly-2025-02-14
          fenix.packages.${system}.nightly-2025-05-08
          fenix.packages.${system}.toolchainOf { version = "1.68.0"; }
          fenix.packages.${system}.toolchainOf { version = "1.70.0"; }
          fenix.packages.${system}.toolchainOf { version = "1.72.1"; }
          fenix.packages.${system}.toolchainOf { version = "1.73.0"; }
          fenix.packages.${system}.toolchainOf { version = "1.77.2"; }
          fenix.packages.${system}.toolchainOf { version = "1.80.0"; }
          fenix.packages.${system}.toolchainOf { version = "1.81.0"; }
          fenix.packages.${system}.toolchainOf { version = "1.85.0"; }
          fenix.packages.${system}.toolchainOf { version = "1.85.1"; }
          fenix.packages.${system}.toolchainOf { version = "1.86.0"; }
        ];

        cargoTools = with pkgs; [
          (rustPlatform.buildRustPackage rec {
            pname = "cross";
            version = "0.2.5";
            src = fetchCrate {
              inherit pname version;
              hash = "sha256-+wZtq2y7d1zv0y3p6ZqvA3n8o8F4w4V2v6p4v4w4v4w=";
            };
            cargoSha256 = "sha256-+wZtq2y7d1zv0y3p6ZqvA3n8o8F4w4V2v6p4v4w4v4w=";
          })
          cargo-zigbuild
          cbindgen
          wasm-pack
          just
          sccache
          bindgen
          cxxbridge-cmd
        ];
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = toolchains ++ cargoTools ++ [
            pkgs.zig
            pkgs.pkg-config
            pkgs.openssl
            pkgs.llvmPackages_16.llvm
          ];

          shellHook = ''
            echo "==> Rust multi-toolchain cross-compilation shell ready!"
            echo "Available Rust toolchains (via fenix):"
            echo "  - stable, beta, nightly, nightly-2025-02-14, nightly-2025-05-08, 1.68.0, ... 1.86.0"
            echo "You can use e.g. 'rustc +nightly-2025-05-08 --version'"
            echo "Cargo tools (cross, zigbuild, cbindgen, wasm-pack, just, sccache, bindgen, cxxbridge-cmd) are available."
          '';
        };
      }
    );
}


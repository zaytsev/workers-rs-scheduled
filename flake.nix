{
  description = "Basic Rust dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-compat,
    fenix,
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        overlays = [fenix.overlays.default];
        pkgs = import nixpkgs {inherit system overlays;};

        projectConfig = builtins.fromTOML (builtins.readFile ./Cargo.toml);

        package = let
          toolchain = with fenix.packages.${system};
            combine [
              stable.toolchain
              targets.wasm32-unknown-unknown.stable.rust-std
            ];
        in
          (pkgs.makeRustPlatform {
            cargo = toolchain;
            rustc = toolchain;
          })
          .buildRustPackage {
            pname = projectConfig.package.name;
            version = projectConfig.package.version;
            src = ./.;

            doCheck = false;

            nativeBuildInputs = with pkgs; [
              pkg-config
              openssl
            ];

            buildInputs = with pkgs; [
              pkg-config
              openssl
            ];

            cargoLock = {
              lockFile = ./Cargo.lock;
            };
          };
      in {
        packages = flake-utils.lib.flattenTree {
          main = package;
        };
        defaultPackage = package;

        devShell =
          pkgs.mkShell
          {
            buildInputs = with pkgs; [
              (
                with fenix.packages.${system};
                  combine [
                    stable.rustc
                    stable.cargo
                    stable.rust-src
                    stable.rustfmt
                    targets.wasm32-unknown-unknown.stable.rust-std
                  ]
              )
              cargo-edit
              cargo-update
              cargo-outdated
              cargo-audit
              cargo-expand

              cocogitto

              nodejs_20
              nodePackages.wrangler
              nodePackages.npm

              worker-build
              wasm-pack
              wasm-bindgen-cli
              esbuild

              openssl
              pkg-config
            ];
          };
      }
    );
}

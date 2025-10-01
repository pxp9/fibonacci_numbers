{
  description = "A Nix-flake-based Elixir development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      overlays = [
        rust-overlay.overlays.default
        (final: prev: {
          rustToolchain =
            let
              rust = prev.rust-bin;
            in
            if builtins.pathExists ./rust-toolchain.toml then
              rust.fromRustupToolchainFile ./rust-toolchain.toml
            else if builtins.pathExists ./rust-toolchain then
              rust.fromRustupToolchainFile ./rust-toolchain
            else
              rust.stable.latest.default.override {
                extensions = [
                  "rust-src"
                  "rustfmt"
                ];
              };
        })

        self.overlays.default
      ];

      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
              inherit overlays;
            };
          }
        );
    in
    {
      overlays.default = final: prev: rec {
        # documentation
        # https://nixos.org/manual/nixpkgs/stable/#sec-beam

        # ==== ERLANG ====

        # use whatever version is currently defined in nixpkgs
        # erlang = pkgs.beam.interpreters.erlang;

        # use latest version of Erlang 27
        erlang = final.beam.interpreters.erlang;

        # specify exact version of Erlang OTP
        # erlang = pkgs.beam.interpreters.erlang.override {
        #   version = "26.2.2";
        #   sha256 = "sha256-7S+mC4pDcbXyhW2r5y8+VcX9JQXq5iEUJZiFmgVMPZ0=";
        # }

        # ==== BEAM packages ====

        # all BEAM packages will be compile with your preferred erlang version
        pkgs-beam = final.beam.packagesWith erlang;

        # ==== Elixir ====

        # use whatever version is currently defined in nixpkgs
        # elixir = pkgs-beam.elixir;

        # use latest version of Elixir 1.17
        elixir = pkgs-beam.elixir;

        # specify exact version of Elixir
        # elixir = pkgs-beam.elixir.override {
        #   version = "1.17.1";
        #   sha256 = "sha256-a7A+426uuo3bUjggkglY1lqHmSbZNpjPaFpQUXYtW9k=";
        # };
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                # use the Elixr/OTP versions defined above; will also install OTP, mix, hex, rebar3
                elixir

                erlang

                # mix needs it for downloading dependencies
                git

                watchman

                # probably needed for your Phoenix assets
                nodejs_20

                elixir-ls

                graphviz

                mermaid-cli

                jpegoptim

                optipng

                phrase-cli

                terraform

                awscli2

                ## Rust
                rustToolchain
                openssl
                pkg-config
                cargo-deny
                cargo-edit
                cargo-expand
                cargo-watch
                rust-analyzer
              ]
              ++
                # Linux only
                pkgs.lib.optionals pkgs.stdenv.isLinux (
                  with pkgs;
                  [
                    inotify-tools
                    libnotify
                  ]
                )
              ++
                # macOS only
                pkgs.lib.optionals pkgs.stdenv.isDarwin (
                  with pkgs;
                  [
                    terminal-notifier
                    darwin.apple_sdk.frameworks.CoreFoundation
                    darwin.apple_sdk.frameworks.CoreServices
                  ]
                );
          };
        }
      );
    };
}

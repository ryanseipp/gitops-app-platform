{
  description = "On-Prem-Like Kubernetes Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports = [ inputs.treefmt-nix.flakeModule ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
        perSystem =
          { pkgs, system, ... }:
          let
            craneLib = (inputs.crane.mkLib pkgs).overrideToolchain (
              p:
              p.rust-bin.stable.latest.default.override {
                targets = [
                  "x86_64-unknown-linux-musl"
                  "aarch64-unknown-linux-musl"
                ];
              }
            );

            # Common arguments can be set here to avoid repeating them later
            # Note: changes here will rebuild all dependency crates
            commonArgs = {
              src = craneLib.cleanCargoSource ./app;
              strictDeps = true;
              nativeBuildInputs = [ pkgs.git ];
            };

            hello-world = craneLib.buildPackage (
              commonArgs
              // {
                cargoArtifacts = craneLib.buildDepsOnly commonArgs;
              }
            );
          in
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ (import inputs.rust-overlay) ];
            };

            treefmt = {
              settings.global.excludes = [
                ".envrc"
                "LICENSE"
                "*.gitignore"
                "*.gitkeep"
                "target/"
              ];
              programs = {
                nixfmt.enable = true;
                rustfmt.enable = true;
                terraform.enable = true;
                prettier = {
                  enable = true;
                  includes = [
                    "*.md"
                    "*.json"
                    "*.yaml"
                    "*.yml"
                  ];
                  settings.proseWrap = "always";
                };
                taplo = {
                  enable = true;
                  settings = {
                    include = [
                      "*.toml"
                      "Cargo.lock"
                    ];
                    formatting.array_auto_expand = false;
                  };
                };
              };
            };

            checks = {
              inherit hello-world;
            };

            packages.default = hello-world;

            devShells.default = craneLib.devShell {
              checks = inputs.self.checks;

              inputsFrom = [
                hello-world
              ];

              packages = with pkgs; [
                argocd
                cargo-watch
                cilium-cli
                helmfile
                k9s
                kind
                kubectl
                kubectx
                kubernetes-helm
                kustomize
                opentofu
                yq-go
              ];
            };
          };
      }
    );
}

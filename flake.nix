{
  description = "Minimal, fast async engine for OCaml";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    bytestring = {
      url = "github:riot-ml/bytestring";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.minttea.follows = "minttea";
    };

    config = {
      url = "github:ocaml-sys/config.ml";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.minttea.follows = "minttea";
    };

    libc = {
      url = "github:ocaml-sys/libc.ml";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.config.follows = "config";
    };

    minttea = {
      url = "github:leostera/minttea";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rio = {
      url = "github:riot-ml/rio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inherit (pkgs) ocamlPackages mkShell lib;
          inherit (ocamlPackages) buildDunePackage;
          name = "gluon";
          version = "0.0.9+dev";
        in
          {
            devShells = {
              default = mkShell {
                buildInputs = with ocamlPackages; [
                  dune_3
                  ocaml
                  utop
                  ocamlformat
                ];
                inputsFrom = [ self'.packages.default ];
                packages = builtins.attrValues {
                  inherit (ocamlPackages) ocaml-lsp ocamlformat-rpc-lib;
                };
              };
            };

            packages = {
              default = buildDunePackage {
                inherit version;
                pname = name;
                propagatedBuildInputs = with ocamlPackages; [
                  inputs'.bytestring.packages.default
                  inputs'.config.packages.default
                  inputs'.libc.packages.default
                  inputs'.rio.packages.default
                  uri
                ]
                ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.darwin.apple_sdk.frameworks.System ];
                src = ./.;
              };
            };
          };
    };
}

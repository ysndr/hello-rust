{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  inputs.capacitor.url = "github:flox/capacitor";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, capacitor, flake-utils }:
    let
      flake = flake-utils.lib.eachDefaultSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        with pkgs;
        rec {
          packages = flake-utils.lib.flattenTree {
            hello = rustPlatform.buildRustPackage rec {
              name = "flake-info";
              src = ./.;
              cargoLock.lockFile = ./Cargo.lock;
              nativeBuildInputs = [ pkg-config ];
              buildInputs = [ openssl openssl.dev ]
                ++ lib.optional pkgs.stdenv.isDarwin [ libiconv darwin.apple_sdk.frameworks.Security ];
            };
          };
          defaultPackage = packages.hello;
        }
      );

      capacitor-apps = capacitor.lib.makeApps self nixpkgs;

    in
    nixpkgs.lib.recursiveUpdate flake capacitor-apps;

}

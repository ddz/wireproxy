{
  description = "Wireguard client that exposes itself as a socks5/http proxy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        version = self.shortRev or self.dirtyShortRev or "dev";
      in
      {
        packages = rec {
          wireproxy = pkgs.buildGoModule {
            pname = "wireproxy";
            inherit version;
            src = ./.;

            vendorHash = "sha256-4fxDBiuleDI0UcX67Ki7o/g/gGXxpfa0PgLwhYRay1M=";

            env.CGO_ENABLED = 0;

            subPackages = [ "cmd/wireproxy" ];

            ldflags = [
              "-s"
              "-w"
              "-X=main.version=${version}"
            ];

            meta = {
              description = "Wireguard client that exposes itself as a socks5/http proxy";
              homepage = "https://github.com/windtf/wireproxy";
              license = pkgs.lib.licenses.isc;
              mainProgram = "wireproxy";
              platforms = pkgs.lib.platforms.unix;
            };
          };
          default = wireproxy;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            gotools
          ];
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.wireproxy}/bin/wireproxy";
        };
      });
}

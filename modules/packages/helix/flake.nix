{
  description = "Helix text editor built via cargo install for nix-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ (import rust-overlay) ];
            };
            rustToolchain = pkgs.rust-bin.stable.latest.default;
          in
          f pkgs rustToolchain
        );
    in
    {
      packages = forAllSystems (
        pkgs: rustToolchain:
        let
          helix = pkgs.stdenv.mkDerivation {
            pname = "helix";
            version = "latest";

            dontCheckForBrokenSymlinks = true;

            src = pkgs.fetchFromGitHub {
              owner = "helix-editor";
              repo = "helix";
              rev = "master";
              # Replace this with an actual hash after first build:
              sha256 = "sha256-tL2I302ZrTeo13D99vg4v/VajVCSHdOx5RncpMcjqa0=";
            };

            nativeBuildInputs = [
              rustToolchain
              pkgs.pkg-config
              pkgs.lld
              pkgs.cacert
              pkgs.git
              pkgs.makeWrapper
            ];

            buildPhase = ''
              export RUSTFLAGS="-C target-cpu=native"
              export CARGO_HOME=$TMPDIR/cargo

              mkdir -p $out/lib

              mkdir -p $CARGO_HOME
              cargo install \
                --profile opt \
                --config 'build.rustflags="-C target-cpu=native"' \
                --path helix-term \
                --locked \
                --root $out

                cp -r runtime $out/lib
            '';

            meta = with pkgs.lib; {
              description = "Post-modern text editor built from Helix source via Cargo";
              homepage = "https://github.com/helix-editor/helix";
              license = licenses.mit;
              maintainers = [ maintainers.your-name ];
              platforms = platforms.darwin;
            };
          };
        in
        {
          default = helix;
        }
      );

      devShells = forAllSystems (
        pkgs: rustToolchain:
        pkgs.mkShell {
          buildInputs = [
            rustToolchain
            pkgs.pkg-config
            pkgs.lld
          ];
        }
      );
    };
}

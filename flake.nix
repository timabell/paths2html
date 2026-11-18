{
  description = "paths2html - turn a list of file paths into a collapsible html tree (prebuilt binary from GitHub releases)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "0.0.5";

      assets = {
        x86_64-linux = {
          name = "paths2html-linux-x86_64.tar.gz";
          sha256 = "fbd880bd4c3c6f86b050246b8b3ff849606b5cca0afe5dacc7de680d4dbe7f8b";
        };
        x86_64-darwin = {
          name = "paths2html-macos-x86_64.tar.gz";
          sha256 = "222e347e7d3b8a1ef0b75cf6aca52680ff0ad5c02a6e1038710bec19552c79ff";
        };
        aarch64-darwin = {
          name = "paths2html-macos-aarch64.tar.gz";
          sha256 = "75f4c477a65637c2ff3fd232a8433750ab778ea0bf2badbad7d6a6e2cc161dd8";
        };
      };

      systems = builtins.attrNames assets;
      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkPackage = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          asset = assets.${system};
        in
        pkgs.stdenvNoCC.mkDerivation {
          pname = "paths2html";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://github.com/timabell/paths2html/releases/download/v${version}/${asset.name}";
            sha256 = asset.sha256;
          };

          dontUnpack = true;

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            tar -xzf $src -C $out/bin paths2html
            chmod +x $out/bin/paths2html
            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Turn a list of file paths into a collapsible html tree";
            homepage = "https://github.com/timabell/paths2html";
            license = licenses.agpl3Only;
            platforms = systems;
            mainProgram = "paths2html";
          };
        };
    in
    {
      packages = forAllSystems (system: {
        default = mkPackage system;
        paths2html = mkPackage system;
      });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${mkPackage system}/bin/paths2html";
        };
      });
    };
}

{
  description = "paths2html - turn a list of file paths into a collapsible html tree (prebuilt binary from GitHub releases)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      version = "0.0.0";

      assets = {
        x86_64-linux = {
          name = "paths2html-linux-x86_64.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
        };
        x86_64-darwin = {
          name = "paths2html-macos-x86_64.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
        };
        aarch64-darwin = {
          name = "paths2html-macos-aarch64.tar.gz";
          sha256 = "0000000000000000000000000000000000000000000000000000000000000000";
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

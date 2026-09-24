{
  description = "Linh-Long Desktop Shell - The Ultimate Unified Wayland Desktop Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, quickshell }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          qs = quickshell.packages.${system}.default;
        in
        {
          default = pkgs.stdenv.mkDerivation {
            pname = "linh-long-shell";
            version = "1.0.0";
            src = ./.;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              mkdir -p $out/share/linh-long-shell
              cp -r * $out/share/linh-long-shell/

              mkdir -p $out/bin
              makeWrapper ${qs}/bin/quickshell $out/bin/linh-long-shell \
                --add-flags "-p $out/share/linh-long-shell"
            '';
          };
        }
      );

      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          qs = quickshell.packages.${system}.default;
        in
        {
          default = pkgs.mkShell {
            packages = [
              qs
              pkgs.pipewire
              pkgs.upower
            ];
          };
        }
      );
    };
}

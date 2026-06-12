# Run with `nix-shell shell.nix`
let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pkg-config
    wrapGAppsHook4
    cargo 
    cargo-tauri
    nodejs 
    pnpm
    rustc # Needed for dev server (pnpm tauri dev)
  ];

  buildInputs = with pkgs; [
    librsvg
    webkitgtk_4_1
  ];
}

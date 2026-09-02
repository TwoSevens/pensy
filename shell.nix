# Run with `nix-shell shell.nix`
let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pkg-config
    cargo
    cargo-tauri
    nodejs
    pnpm
    rustc # Needed for dev server (pnpm tauri dev)
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = with pkgs; [
    openssl # Needed by rusqlite
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    librsvg
    webkitgtk_4_1
  ];
}
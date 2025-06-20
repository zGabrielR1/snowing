{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nix development tools
    nixpkgs-fmt
    statix
    deadnix
    alejandra
    
    # Git tools
    git
    gh
    delta
    
    # Shell tools
    zsh
    fzf
    bat
    eza
    ripgrep
    fd
    
    # Documentation
    man-pages
    nixos-option
  ];
  
  shellHook = ''
    echo "🔧 NixOS Development Shell"
    echo "Available commands:"
    echo "  nixpkgs-fmt - Format Nix files"
    echo "  statix - Lint Nix files"
    echo "  deadnix - Find dead code in Nix files"
    echo "  alejandra - Alternative Nix formatter"
    echo ""
  '';
} 
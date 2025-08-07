# CRUSH Guide for snowing (NixOS + Home Manager)

- Dev shell: nix develop
- Format Nix: alejandra . or nix fmt (uses formatter from flake)
- Lint Nix: statix check . && deadnix .
- Fix lint: statix fix .
- Nixpkgs fmt (alt): nixpkgs-fmt -w .
- Build system: nix build .#nixosConfigurations.laptop.config.system.build.toplevel
- Switch system: sudo nixos-rebuild switch --flake .#laptop
- Build HM: nix build .#homeConfigurations.zrrg.activationPackage
- Switch HM: home-manager switch --flake .#zrrg
- Check flake: nix flake check
- Show drv: nix show-derivation .#nixosConfigurations.laptop.config.system.build.toplevel
- CI mirrors build.yml; prefer nix build targets above

Code style (Nix):
- Imports: prefer flake-parts; keep modules under modules/{nixos,home}; aggregate in default.nix per dir
- Formatting: run alejandra; no trailing whitespace; 2 spaces indent; one attr per line for long sets
- Types: use lib types in option declarations; default =; example =; keep booleans explicit; prefer lists over sets for package collections
- Naming: lower-kebab for files; lowerCamelAttrs for option names; concise module option names; consistent host/user ids (laptop, zrrg)
- Structure: inputs pinned in flake.nix; use inherit to avoid repetition; pass extraSpecialArgs via flake-parts
- Errors: avoid throw except for truly unsupported platforms; validate with assertions in modules
- Packages: add to modules/nixos/packages.nix or modules/home/...; do not hardcode versions when nixpkgs provides one
- Secrets: never commit secrets; use age/agenix if introduced later; do not echo tokens in logs

Notes:
- Run nix fmt and statix/deadnix before commits
- For single “test”: use nix flake check -L to run evaluations; limit scope via --override-input or by building a single attr path
- Ignore: add .crush/ to .gitignore for agent state

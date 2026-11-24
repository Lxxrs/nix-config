# nix-config

Nix flake for my machines.

| Host     | Machine            | System             | Config                                          |
| -------- | ------------------ | ------------------ | ----------------------------------------------- |
| `m3-air` | MacBook Air M3     | macOS + nix-darwin | `configuration` module in [`flake.nix`](flake.nix) |
| `t480`   | ThinkPad T480      | NixOS              | [`hosts/t480/`](hosts/t480/)                    |

## Layout

```sh
.
├── flake.nix                  # inputs, the m3-air config, all outputs
├── flake.lock                 # pinned versions of every input
└── hosts/
    └── t480/
        ├── configuration.nix
        └── hardware-configuration.nix   # generated, don't edit by hand
```

The Mac config lives directly in `flake.nix` for now. It moves to
`hosts/m3-air/` once it grows big enough to be worth splitting.

## Quick Start

### MacBook

```sh
# Update
sudo nix flake update

# Build
sudo darwin-rebuild build --flake ~/nix-config#m3-air

# Apply
sudo darwin-rebuild switch --flake ~/nix-config#m3-air
```

```sh
# Rollback
sudo darwin-rebuild --rollback
```

### Thinkpad

```sh
# Update
nix flake update

# Build
nixos-rebuild build --flake ~/nix-config#t480

# Apply
nixos-rebuild switch --flake ~/nix-config#t480
```

```sh
# Rollback
nixos-rebuild switch --rollback
```

## Dev

```sh
# format all .nix files
nix fmt *.nix
```

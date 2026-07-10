# dotfiles

Personal, reproducible dev environment config — managed with [GNU Stow](https://www.gnu.org/software/stow/), bootstrapped with a single install script.

## What's inside

| Tool | Config path in repo | Symlinked to |
|---|---|---|
| Alacritty | `alacritty/.config/alacritty/` | `~/.config/alacritty/` |
| tmux | `tmux/.tmux.conf` | `~/.tmux.conf` |
| Neovim (LazyVim) | `nvim/.config/nvim/` | `~/.config/nvim/` |
| Starship | `starship/.config/starship.toml` | `~/.config/starship.toml` |
| Zsh | `zsh/.zshrc` | `~/.zshrc` |

Theme: [nightfox](https://github.com/EdenEast/nightfox.nvim) across Alacritty, tmux, and the terminal prompt. Font: JetBrainsMono Nerd Font.

## Fresh machine setup

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` will:
1. Install base system packages (zsh, tmux, neovim, stow, git) via `dnf` (Fedora) or `brew` (macOS)
2. Install rustup + cargo, and set up rust-analyzer
3. Install Alacritty via `cargo install`
4. Install `uv` and `bun`
5. Install Starship prompt
6. Install Oh My Zsh + `zsh-autosuggestions` + `zsh-syntax-highlighting`
7. Install JetBrainsMono Nerd Font
8. Install LazyVim starter (only if `~/.config/nvim` doesn't already exist)
9. Set zsh as the default shell
10. Symlink every config in this repo into place using Stow

The script is idempotent — safe to re-run any time. Existing installs are skipped, not reinstalled.

## Manual Stow usage

If you only want to (re)link a single tool's config instead of running the full script:

```bash
cd ~/dotfiles
stow alacritty   # or tmux, nvim, starship, zsh
```

To remove a symlinked config:

```bash
stow -D <package>
```

## Adding a new config

1. Create a folder under `~/dotfiles/<tool>/` that mirrors the path it needs relative to `$HOME`
   (e.g. `~/dotfiles/foo/.config/foo/config.yml` → symlinks to `~/.config/foo/config.yml`)
2. `mv` the real config file into that folder
3. `stow <tool>` from inside `~/dotfiles`
4. `git add . && git commit`

## Notes

- tmux clipboard integration assumes Wayland (`wl-copy`). If on X11, swap for `xclip`/`xsel` in `tmux/.tmux.conf`.
- Rust tooling assumes `rustup`-managed toolchain; `rust_analyzer` is set to `mason = false` in the nvim LSP config so it uses the rustup-installed binary instead of a Mason-managed one.

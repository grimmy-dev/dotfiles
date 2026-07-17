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
| Claude Code | `claude/.claude/` | `~/.claude/statusline-command.sh` + custom skills |

The full nvim config lives here (`lazy-lock.json` pinned for reproducible plugins), so there's no separate LazyVim clone step. Marketplace Claude skills and the caveman plugin reinstall themselves, so only my own skills are stored.

Theme: [nightfox](https://github.com/EdenEast/nightfox.nvim) across Alacritty, tmux, and the terminal prompt. Font: JetBrainsMono Nerd Font.

## Fresh machine setup

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs with `set -euo pipefail` and prints `[n/10]` progress headers. It will:
1. Install base packages (zsh, tmux, neovim, stow, git, curl, jq, alacritty) via `dnf` (Fedora) or `brew` (macOS)
2. Install rustup + rust-analyzer
3. Install Starship prompt
4. Install Oh My Zsh + `zsh-autosuggestions` + `zsh-syntax-highlighting`
5. Install JetBrainsMono Nerd Font (macOS gets it from a cask)
6. Set zsh as the default shell
7. Symlink every package into place with `stow -R` (backs up any real config already there)
8. Reinstall the caveman plugin via the Claude Code CLI
9. Merge only the `statusLine` key into `~/.claude/settings.json` (rest untouched)
10. Point `~/.claude/CLAUDE.md` at `AGENTS.md`

The script is idempotent — safe to re-run any time. Existing installs are skipped, not reinstalled.

## Manual Stow usage

If you only want to (re)link a single tool's config instead of running the full script:

```bash
cd ~/dotfiles
stow alacritty   # or tmux, nvim, starship, zsh, claude
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

## Agent rules

`AGENTS.md` is the single source of truth for how coding agents work on my repos, and `STANDARDS.md` holds the coding standards it references. Both are cross-tool (Cursor, Codex, etc. read `AGENTS.md` directly).

Claude Code reads `CLAUDE.md`, not `AGENTS.md`, so `install.sh` writes a global `~/.claude/CLAUDE.md` with a single import line:

```
@~/dotfiles/AGENTS.md
```

That pulls the rules into every session, every repo — no per-project file needed.

## Notes

- tmux clipboard integration assumes Wayland (`wl-copy`). If on X11, swap for `xclip`/`xsel` in `tmux/.tmux.conf`.
- Rust tooling assumes `rustup`-managed toolchain; `rust_analyzer` is set to `mason = false` in the nvim LSP config so it uses the rustup-installed binary instead of a Mason-managed one.

# dotfiles

My dev environment, kept in one place so a fresh machine is a clone and a script away.

I rebuilt this setup by hand too many times, each time slightly differently, and lost an evening to it every time. Now it is a repo. [GNU Stow](https://www.gnu.org/software/stow/) does the symlinking, `install.sh` does everything else.

## What's inside

| Tool | Config path in repo | Symlinked to |
|---|---|---|
| Alacritty | `alacritty/.config/alacritty/` | `~/.config/alacritty/` |
| tmux | `tmux/.tmux.conf` | `~/.tmux.conf` |
| Neovim (LazyVim) | `nvim/.config/nvim/` | `~/.config/nvim/` |
| Starship | `starship/.config/starship.toml` | `~/.config/starship.toml` |
| Zsh | `zsh/.zshrc` | `~/.zshrc` |
| Claude Code | `claude/.claude/` | `~/.claude/statusline-command.sh` + custom skills |

The whole nvim config is here, `lazy-lock.json` included, so plugins come back at the same versions and there is no separate LazyVim clone step. Marketplace Claude skills and the caveman plugin reinstall themselves, so only the skills I wrote are committed.

Theme is [nightfox](https://github.com/EdenEast/nightfox.nvim) everywhere: Alacritty, tmux, the prompt. Font is JetBrainsMono Nerd Font. One palette across the whole screen is worth more to me than picking a favourite theme per tool.

## Fresh machine setup

```bash
git clone https://github.com/grimmy-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs under `set -euo pipefail` and prints `[n/10]` headers so I can see where it stopped. It will:

1. Install base packages (zsh, tmux, neovim, stow, git, curl, jq, alacritty) via `dnf` on Fedora or `brew` on macOS
2. Install rustup + rust-analyzer
3. Install the Starship prompt
4. Install Oh My Zsh + `zsh-autosuggestions` + `zsh-syntax-highlighting`
5. Install JetBrainsMono Nerd Font (macOS gets it from a cask)
6. Set zsh as the default shell
7. Symlink every package with `stow -R`, backing up any real config already sitting there
8. Reinstall the caveman plugin through the Claude Code CLI
9. Merge only the `statusLine` key into `~/.claude/settings.json` and leave the rest alone
10. Point `~/.claude/CLAUDE.md` at `AGENTS.md`

It is idempotent. Re-running skips what is already installed instead of reinstalling it, because a bootstrap script I am afraid to run twice is not much of a bootstrap script.

## tmux keys

Prefix is `Ctrl+Space`. Press it, release, then the key.

| Key | Does |
|---|---|
| `^space` then `?` | Popup listing every binding with a description |
| `^space` then `\|` / `-` | Split right / split down, in the current directory |
| `^space` then `r` | Reload `~/.tmux.conf` |
| `^space` then `H J K L` | Resize the focused pane, repeatable |
| `^t` / `^w` | New window / kill window |
| `Alt+arrows` | Move between panes |
| `Alt+Shift+←/→` | Previous / next window |
| `Ctrl+Shift+←/→` | Drag the current window along the tab order |

The status line carries the session name, the window tabs, the keys above, and the clock, so I stop forgetting bindings I set up myself. The session block turns yellow while the prefix is held, which killed the "did that register" pause.

## Manual Stow usage

To relink one tool instead of running the whole script:

```bash
cd ~/dotfiles
stow alacritty   # or tmux, nvim, starship, zsh, claude
```

To unlink it:

```bash
stow -D <package>
```

## Adding a new config

1. Make a folder under `~/dotfiles/<tool>/` mirroring the path it needs relative to `$HOME`
   (`~/dotfiles/foo/.config/foo/config.yml` becomes `~/.config/foo/config.yml`)
2. `mv` the real config into it
3. `stow <tool>` from inside `~/dotfiles`
4. `git add . && git commit`

## Agent rules

`AGENTS.md` is the one source of truth for how coding agents work in my repos, and `STANDARDS.md` holds the coding standards it points at. Both are cross-tool, so Cursor, Codex and the rest read `AGENTS.md` directly.

Claude Code reads `CLAUDE.md` rather than `AGENTS.md`, so `install.sh` writes a global `~/.claude/CLAUDE.md` holding one import line:

```
@~/dotfiles/AGENTS.md
```

That pulls the rules into every session in every repo, with no per-project file to maintain.

## Notes

- tmux clipboard assumes Wayland (`wl-copy`). On X11, swap it for `xclip` or `xsel` in `tmux/.tmux.conf`.
- Rust tooling assumes a rustup-managed toolchain. `rust_analyzer` is set to `mason = false` in the nvim LSP config so it uses the rustup binary rather than a second Mason-managed copy.

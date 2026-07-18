#!/usr/bin/env bash
set -euo pipefail

# Reproducible dotfiles installer for Fedora (Linux) and macOS (Darwin).
DOTFILES="${DOTFILES:-$HOME/dotfiles}"
OS="$(uname -s)"

STEP=0
TOTAL=10
step() { STEP=$((STEP + 1)); printf '\n\033[1;34m[%d/%d]\033[0m %s\n' "$STEP" "$TOTAL" "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

# Move a real (non-symlink) target aside so stow can own it. Idempotent.
backup_if_real() {
  local t="$1"
  if [ -e "$t" ] && [ ! -L "$t" ]; then
    mv "$t" "$t.pre-dotfiles.$(date +%s)"
    echo "  backed up existing $t"
  fi
}

echo "==> Detected OS: $OS"

# 1. Base packages (alacritty from the package manager, not a slow cargo build)
step "Installing base packages"
case "$OS" in
  Linux)
    sudo dnf install -y zsh tmux neovim stow git curl unzip jq alacritty
    FONT_DIR="$HOME/.local/share/fonts" ;;
  Darwin)
    have brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install zsh tmux neovim stow git curl jq
    brew install --cask alacritty font-jetbrains-mono-nerd-font
    FONT_DIR="$HOME/Library/Fonts" ;;
  *)
    echo "Unsupported OS: $OS"; exit 1 ;;
esac

# 2. Rust toolchain (rust-analyzer for the nvim rust config)
step "Installing Rust toolchain"
if ! have rustup; then
  curl -# --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"
rustup component add rust-analyzer

# 3. Starship prompt
step "Installing Starship"
have starship || curl -# -sS https://starship.rs/install.sh | sh -s -- -y

# 4. Oh My Zsh + plugins
step "Installing Oh My Zsh + plugins"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -# -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 5. Nerd Font (macOS gets it from the cask above)
step "Installing Nerd Font"
if [ "$OS" = "Linux" ]; then
  mkdir -p "$FONT_DIR"
  if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    curl -# -Lo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    have fc-cache && fc-cache -f
  fi
else
  echo "  provided by font-jetbrains-mono-nerd-font cask"
fi

# 6. Default shell
step "Setting zsh as default shell"
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" || echo "  chsh failed, set it manually later"
fi

# 7. Symlink dotfiles with Stow (-R = restow, idempotent re-runs)
step "Symlinking dotfiles with Stow"
backup_if_real "$HOME/.config/nvim"                    # we now own the whole nvim config
backup_if_real "$HOME/.claude/statusline-command.sh"   # replace any pre-existing real script
for s in grill-me implement improve-codebase-architecture teach to-spec to-tickets wayfinder; do
  rm -rf "$HOME/.claude/skills/$s"           # drop stale manager symlinks so stow can place ours
done
for pkg in alacritty tmux nvim starship zsh claude; do
  stow -R -t "$HOME" -d "$DOTFILES" "$pkg"
  echo "  stowed $pkg"
done

# 8. Caveman plugin (drives caveman mode + the statusline badge)
step "Installing caveman plugin"
if have claude; then
  claude plugin marketplace add JuliusBrussee/caveman 2>/dev/null || true
  claude plugin install caveman@caveman 2>/dev/null || echo "  install caveman manually: claude plugin install caveman@caveman"
else
  echo "  claude CLI not found, install it then run: claude plugin install caveman@caveman"
fi

# 9. Wire statusline into settings.json without touching the rest of it
step "Wiring statusline into ~/.claude/settings.json"
SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
tmp="$(mktemp)"
jq --arg cmd "bash \$HOME/.claude/statusline-command.sh" \
  '.statusLine = {type: "command", command: $cmd}' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"

# 10. Global agent rules: CLAUDE.md just points Claude Code at the canonical AGENTS.md
step "Pointing ~/.claude/CLAUDE.md at AGENTS.md"
# tilde stays literal here; bash would expand it if used in a ${var/pat/repl} replacement
printf '@~/%s/AGENTS.md\n' "${DOTFILES#$HOME/}" > "$HOME/.claude/CLAUDE.md"

printf '\n\033[1;32m==> Done.\033[0m Restart your shell for all changes to take effect.\n'

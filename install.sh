#!/usr/bin/env bash
set -e

OS="$(uname -s)"
echo "==> Detected OS: $OS"

# 1. Base system packages
if [ "$OS" = "Linux" ]; then
  sudo dnf install -y zsh tmux neovim stow git curl unzip
  FONT_DIR="$HOME/.local/share/fonts"
elif [ "$OS" = "Darwin" ]; then
  if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install zsh tmux neovim stow git curl
  FONT_DIR="$HOME/Library/Fonts"
else
  echo "Unsupported OS: $OS"
  exit 1
fi

# 2. rustup + cargo
if ! command -v rustup &> /dev/null; then
  curl -# --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source "$HOME/.cargo/env"
rustup component add rust-analyzer

# 3. Alacritty via cargo
if ! command -v alacritty &> /dev/null; then
  cargo install alacritty
fi

# 4. uv + bun
# if ! command -v uv &> /dev/null; then
#   curl -# -LsSf https://astral.sh/uv/install.sh | sh
# fi
# if ! command -v bun &> /dev/null; then
#   curl -# -fsSL https://bun.sh/install | bash
# fi

# 5. Starship
if ! command -v starship &> /dev/null; then
  curl -# -sS https://starship.rs/install.sh | sh -s -- -y
fi

# 6. Oh My Zsh + plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -# -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone --progress https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone --progress https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 7. Nerd Font
mkdir -p "$FONT_DIR"
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
  curl -# -Lo /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
  command -v fc-cache &> /dev/null && fc-cache -fv
fi

# 8. LazyVim starter
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone --progress https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
fi

# 9. Set zsh as default shell
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)"
fi

# 10. Symlink all dotfiles with Stow
cd "$HOME/dotfiles"
stow alacritty
stow tmux
stow nvim
stow starship
stow zsh

echo "==> Done. Restart your shell for all changes to take effect."
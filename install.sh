#! /bin/zsh

# Quit if you encounter error
set -e

# Color constants
GREEN='\033[1;32m'
RESET_COLOR='\033[0m'
## Hard-coded for internal use-case
CURRENT_USER_HOME='/home/user'
CURRENT_USER=$(cat /etc/passwd | grep -P "$CURRENT_USER_HOME" | cut -d: -f1)

printf "\n%bInstalling generic dependencies for Ubuntu...%b\n\n" "$GREEN" "$RESET_COLOR"

function get_backup {
  mv ~/"$1" ~/"$1"_"$(date +%s)" || echo "No $1 file already available for backup. Skipping"
}

# Install dependencies
apt update && apt -y upgrade
apt remove -y fzf
DEBIAN_FRONTEND=noninteractive apt -y install \
tzdata \
pydf build-essential libyaml-dev libssl-dev postgresql-client \
pv jq fonts-inconsolata python3-pip i3lock vim htop lighttpd xsel pigz ncdu tmux \
ruby-build thefuck software-properties-common stow bash zsh coreutils img2pdf dateutils shellcheck

# fzf install
# Install via git to include shell-bindings since it is currently not supported if installed via package manager in Ubuntu
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && $(yes | ~/.fzf/install) || echo "fzf already installed" 

# Mise install
CPU_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then
  CPU_ARCH=arm64
fi
apt update -y && apt install -y gpg sudo wget curl
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=$CPU_ARCH] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
apt update
apt install -y mise

printf "\n\n%b Stowing dotfiles... %b \n" "$GREEN" "$RESET_COLOR"

get_backup .bash_profile 
get_backup .bashrc 
get_backup .profile 
get_backup .zlogin 
get_backup .zshrc
get_backup .gitconfig
stow config -t ~/
stow dotfile -t ~/
stow vim -t ~/

# Completion for git in zsh shell
mkdir -p "$HOME"/.zsh/functions && cp "$HOME"/.dotfilerc/git/git-completion.zsh "$HOME"/.zsh/functions/_git

###########################
# Setup command line tools
###########################

# Setup base directory
mkdir -p "$HOME"/apps/

##############################

case $(echo "$SHELL" | rev | cut -d'/' -f1 | rev) in
  bash)
    source "$HOME"/.bashrc
    ;;
  zsh)
    source "$HOME"/.zshrc
    ;;
esac

echo "debug logs - current user - $(whoami)"
echo "debug logs - target user - $CURRENT_USER"

printf "\n\n%b Copied all source files %b \n" "$GREEN" "$RESET_COLOR"

# For ruby version install check https://stackoverflow.com/a/77857095/2981954
printf "\n\n%b Installing ruby... %b \n" "$GREEN" "$RESET_COLOR"
mise use -g ruby@3.3.6 || echo "Ruby already installed"

printf "\n\n%b Installing nodejs... %b \n" "$GREEN" "$RESET_COLOR"
mise use -g nodejs@20.12.0 || echo "nodejs already installed"

printf "\n\n%b Installing python... %b \n" "$GREEN" "$RESET_COLOR"
mise use -g python@3.12.0 || echo "python already installed"

printf "\n\n%b Installing pip packages... %b \n" "$GREEN" "$RESET_COLOR"
pip install Pygments tldr csvkit pgcli pyyaml || echo "All packages already installed"

printf "\n\n%b Installing rust... %b \n" "$GREEN" "$RESET_COLOR"
mise use -g rust@latest || echo "rust already installed"

printf "\n\n%b Installing rust binaries... %b \n" "$GREEN" "$RESET_COLOR"
sudo chown -R "$CURRENT_USER" $CURRENT_USER_HOME/.cargo
sudo chwon -R "$CURRENT_USER" $CURRENT_USER_HOME/.cache/mise
sudo -H -u "$CURRENT_USER" bash -l -c "$CURRENT_USER_HOME/.cargo/bin/cargo install bat exa fd-find procs du-dust ripgrep eva lsd"
mise reshim rust

printf "\n\n%b Installing java... %b \n" "$GREEN" "$RESET_COLOR"
mise use -g java@corretto-11.0.25.9.1 || echo "java already installed"

mise use direnv || echo "direnv already installed"
mise reshim direnv

printf "\n\n%bDotfile installation successful! %b \n" "$GREEN" "$RESET_COLOR"

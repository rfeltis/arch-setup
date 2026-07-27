#!/usr/bin/env bash
# One-time bootstrap for a fresh Arch install. Does the bare minimum,
# then hands everything else to Ansible.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/rfeltis/arch-setup/main/bootstrap.sh)
#
# The repo is public and is cloned over HTTPS, so no GitHub credentials are
# needed to get started. SSH keys are set up afterwards, for pushing changes
# back and for private repos -- not as a prerequisite for running this.
set -euo pipefail

REPO_HTTPS="https://github.com/rfeltis/arch-setup.git"
REPO_SSH="git@github.com:rfeltis/arch-setup.git"
REPO_DIR="${REPO_DIR:-$HOME/code/arch-setup}"
SSH_KEY="$HOME/.ssh/id_ed25519"
SKIP_GITHUB="${SKIP_GITHUB:-0}"

if [[ $EUID -eq 0 ]]; then
    echo "Run this as your normal user, not root." >&2
    exit 1
fi

echo ">>> Installing bootstrap packages"
sudo pacman -Syu --needed --noconfirm git ansible base-devel github-cli openssh

# --- Get the code (no auth required) ------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

if [[ -f "${SCRIPT_DIR:-}/playbook.yml" ]]; then
    REPO_DIR="$SCRIPT_DIR"
    echo ">>> Using the checkout at $REPO_DIR"
elif [[ -d "$REPO_DIR/.git" ]]; then
    echo ">>> Updating $REPO_DIR"
    git -C "$REPO_DIR" pull --ff-only
else
    echo ">>> Cloning $REPO_HTTPS"
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_HTTPS" "$REPO_DIR"
fi

# --- Run the playbook ---------------------------------------------------
echo ">>> Running the playbook"
ansible-playbook -i localhost, -c local "$REPO_DIR/playbook.yml" --ask-become-pass "$@"

# --- GitHub identity (optional, for pushing back) -----------------------
# Everything above works without this. Set SKIP_GITHUB=1 to bypass.
if [[ "$SKIP_GITHUB" == "1" ]]; then
    echo ">>> Skipping GitHub setup (SKIP_GITHUB=1)"
else
    if [[ ! -f "$SSH_KEY" ]]; then
        echo ">>> Generating an SSH key"
        mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
        ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "$USER@$(hostname)"
    fi

    if ! gh auth status >/dev/null 2>&1; then
        echo ">>> Log in to GitHub (this will print a one-time code)"
        gh auth login --hostname github.com --git-protocol ssh --web --scopes admin:public_key
    fi

    # Only refresh if an older login lacks the key-upload scope. This is
    # interactive, so its output must never be silenced.
    if ! gh auth status --hostname github.com 2>&1 | grep -q 'admin:public_key'; then
        echo ">>> Granting the admin:public_key scope"
        gh auth refresh --hostname github.com --scopes admin:public_key
    fi

    if ! gh ssh-key list 2>/dev/null | grep -qF "$(awk '{print $2}' "$SSH_KEY.pub")"; then
        echo ">>> Adding the SSH key to your GitHub account"
        # gh auth login may already have uploaded it; a duplicate is not fatal.
        gh ssh-key add "$SSH_KEY.pub" --title "$(hostname)" --type authentication || true
    fi

    # Now that the key is in place, push over SSH instead of HTTPS.
    if [[ -d "$REPO_DIR/.git" ]] && git -C "$REPO_DIR" remote get-url origin 2>/dev/null | grep -q '^https://'; then
        echo ">>> Switching origin to SSH"
        git -C "$REPO_DIR" remote set-url origin "$REPO_SSH"
    fi
fi

echo "Done. Reboot and pick 'Plasma' at the login screen."

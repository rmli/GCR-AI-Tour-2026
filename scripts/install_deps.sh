#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"

SUDO=""
if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

install_azure_cli() {
  if command -v az >/dev/null 2>&1; then
    echo "Azure CLI already installed."
    return 0
  fi

  echo "Installing Azure CLI..."
  $SUDO apt-get update -y
  $SUDO apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg

  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | $SUDO tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null

  AZ_REPO="$(lsb_release -cs)"
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" \
    | $SUDO tee /etc/apt/sources.list.d/azure-cli.list >/dev/null

  $SUDO apt-get update -y
  $SUDO apt-get install -y azure-cli
}

setup_python_env() {
  echo "Setting up Python virtual environment..."
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
  fi

  # shellcheck disable=SC1091
  source "$VENV_DIR/bin/activate"

  python -m pip install --upgrade pip

  echo "Installing Python dependencies..."
  python -m pip install \
    agent-framework \
    azure-identity \
    azure-ai-projects \
    azure-core \
    openai \
    httpx \
    python-dotenv \
    pyyaml
}

main() {
  install_azure_cli
  setup_python_env

  echo "Done. Virtual environment: $VENV_DIR"
  echo "Activate with: source $VENV_DIR/bin/activate"
}

main "$@"

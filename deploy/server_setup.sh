#!/usr/bin/env bash

set -e  # Exit on error
set -o pipefail  # Catch pipeline errors

echo "🚀 Starting server setup..."

# Update and upgrade system packages
echo "📦 Updating package list..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Ensure the system has locales set correctly
echo "🌍 Setting up locale..."
sudo locale-gen en_GB.UTF-8

# Check installed Python version
PYTHON_VERSION=$(python3 -V 2>&1 | awk '{print $2}')
echo "🐍 Installed Python version: $PYTHON_VERSION"

# Install necessary system dependencies
echo "📦 Installing essential packages..."
sudo apt-get install -y software-properties-common \
                        python3-dev sqlite3 python3-pip git \
                        build-essential libssl-dev libffi-dev \
                        python3-setuptools python3-wheel \
                        libpcre3 libpcre3-dev supervisor nginx

# If Python 3.5 is installed, upgrade to Python 3.10
if [[ "$PYTHON_VERSION" == "3.5"* ]]; then
    echo "⚠️ Python 3.5 detected. Upgrading to Python 3.10..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update -y
    sudo apt-get install -y python3.10 python3.10-venv python3.10-dev
fi

# Ensure Python 3.10 exists before setting alternatives
if [[ -f "/usr/bin/python3.10" ]]; then
    echo "🔧 Setting Python 3.10 as default..."
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
    sudo update-alternatives --set python3 /usr/bin/python3.10
else
    echo "❌ Python 3.10 installation failed! Falling back to system default."
fi

# Install pip (latest version for installed Python)
echo "⬆️ Installing/upgrading pip..."
python3 -m pip install --upgrade pip setuptools wheel

# Install Virtualenvwrapper
echo "🐍 Installing Virtualenvwrapper..."
python3 -m pip install virtualenvwrapper

# Add Virtualenvwrapper configuration to bashrc if not already added
if ! grep -q "VIRTUALENV_ALREADY_ADDED" /home/vagrant/.bashrc; then
    echo "🔧 Configuring Virtualenvwrapper..."
    cat <<EOF >> /home/vagrant/.bashrc
# VIRTUALENV_ALREADY_ADDED
export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=/vagrant
source \$(which virtualenvwrapper.sh)
EOF
fi

# Reload bashrc
source /home/vagrant/.bashrc

# Configure Supervisor
echo "🔧 Setting up Supervisor..."
sudo systemctl enable supervisor
sudo systemctl start supervisor

# Configure Nginx
echo "🌐 Configuring Nginx..."
sudo systemctl enable nginx
sudo systemctl restart nginx

echo "✅ Server setup completed successfully! 🚀"

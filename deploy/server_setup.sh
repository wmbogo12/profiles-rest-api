#!/usr/bin/env bash

set -e

# Project configurations
PROJECT_GIT_URL='https://github.com/wmbogo12/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps'
VIRTUALENV_BASE_PATH='/usr/local/virtualenvs'

# Set Ubuntu Language
echo "Setting system locale..."
sudo locale-gen en_GB.UTF-8

# Install Python, SQLite, and pip
echo "Installing system dependencies..."
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git build-essential libssl-dev libpcre3 libpcre3-dev

# Clone the project repository
echo "Cloning project repository..."
mkdir -p $PROJECT_BASE_PATH
if [ ! -d "$PROJECT_BASE_PATH/profiles-rest-api" ]; then
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH/profiles-rest-api
else
    echo "Project already cloned. Pulling the latest changes..."
    cd $PROJECT_BASE_PATH/profiles-rest-api
    git pull
fi

# Create and activate virtual environment
echo "Setting up virtual environment..."
mkdir -p $VIRTUALENV_BASE_PATH
if [ ! -d "$VIRTUALENV_BASE_PATH/profiles_api" ]; then
    python3 -m venv $VIRTUALENV_BASE_PATH/profiles_api
fi

$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install --upgrade pip setuptools wheel
$VIRTUALENV_BASE_PATH/profiles_api/bin/pip install -r $PROJECT_BASE_PATH/profiles-rest-api/requirements.txt

# Run Django migrations
echo "Running database migrations..."
cd $PROJECT_BASE_PATH/profiles-rest-api/src
$VIRTUALENV_BASE_PATH/profiles_api/bin/python manage.py migrate

# Configure Supervisor
echo "Configuring Supervisor..."
if [ -f "$PROJECT_BASE_PATH/profiles-rest-api/deploy/supervisor_profiles_api.conf" ]; then
    cp $PROJECT_BASE_PATH/profiles-rest-api/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
    supervisorctl reread
    supervisorctl update
    supervisorctl restart profiles_api
else
    echo "Supervisor configuration file not found!"
fi

# Configure Nginx
echo "Configuring Nginx..."
if [ -f "$PROJECT_BASE_PATH/profiles-rest-api/deploy/nginx_profiles_api.conf" ]; then
    cp $PROJECT_BASE_PATH/profiles-rest-api/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
    rm -f /etc/nginx/sites-enabled/default
    ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
    nginx -t && systemctl restart nginx.service
else
    echo "Nginx configuration file not found!"
fi

# Set ownership and permissions
echo "Setting permissions..."
chown -R www-data:www-data $PROJECT_BASE_PATH/profiles-rest-api
chmod -R 755 $PROJECT_BASE_PATH/profiles-rest-api

echo "DONE! :)"

#!/usr/bin/env bash

set -e

# Project repository URL
PROJECT_GIT_URL='https://github.com/wmbogo12/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Update package list and install dependencies
echo "Installing dependencies..."
apt-get update
apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git

# Create project directory if it doesn't exist
if [ ! -d "$PROJECT_BASE_PATH" ]; then
    mkdir -p $PROJECT_BASE_PATH
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
else
    echo "Project directory already exists. Pulling latest changes..."
    cd $PROJECT_BASE_PATH
    git pull
fi

# Create and activate virtual environment
if [ ! -d "$PROJECT_BASE_PATH/env" ]; then
    mkdir -p $PROJECT_BASE_PATH/env
    python3 -m venv $PROJECT_BASE_PATH/env
fi

# Install required Python packages
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt
$PROJECT_BASE_PATH/env/bin/pip install uwsgi==2.0.18

# Run migrations and collect static files
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput

# Configure Supervisor
if [ -f "$PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf" ]; then
    cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
    supervisorctl reread
    supervisorctl update
    supervisorctl restart profiles_api
else
    echo "Supervisor configuration file not found!"
fi

# Configure Nginx
if [ -f "$PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf" ]; then
    cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
    rm -f /etc/nginx/sites-enabled/default
    ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
    nginx -t && systemctl restart nginx.service
else
    echo "Nginx configuration file not found!"
fi

# Set correct permissions
chown -R www-data:www-data $PROJECT_BASE_PATH
chmod -R 755 $PROJECT_BASE_PATH

echo "DONE! :)"

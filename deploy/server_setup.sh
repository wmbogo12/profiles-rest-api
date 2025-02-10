#!/usr/bin/env bash

set -e  # Exit on error

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/wmbogo12/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

echo "Updating system packages..."
apt-get update && apt-get upgrade -y

echo "Installing dependencies..."
apt-get install -y python3-dev python3-venv python3-pip sqlite3 supervisor nginx git

# Create project directory if not exists
mkdir -p $PROJECT_BASE_PATH
if [ ! -d "$PROJECT_BASE_PATH/.git" ]; then
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
else
    echo "Project already cloned. Skipping..."
fi

# Create virtual environment if not exists
if [ ! -d "$PROJECT_BASE_PATH/env" ]; then
    python3 -m venv $PROJECT_BASE_PATH/env
fi

# Activate virtual environment and install Python packages
source $PROJECT_BASE_PATH/env/bin/activate
pip install --upgrade pip
pip install -r $PROJECT_BASE_PATH/requirements.txt
pip install uwsgi==2.0.18
deactivate  # Exit virtual environment

# Run migrations and collect static files
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput

# Configure Supervisor
cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Configure Nginx
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "🚀 Deployment completed successfully!"

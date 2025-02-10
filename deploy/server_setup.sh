#!/usr/bin/env bash

set -e  # Exit on error

# Set Git repository URL and project path
PROJECT_GIT_URL='https://github.com/wmbogo12/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

echo "Updating system packages..."
apt-get update && apt-get upgrade -y

echo "Installing dependencies..."
apt-get install -y libpcre3-dev libssl-dev build-essential python3-dev python3-pip python3-setuptools virtualenv sqlite3 supervisor nginx git

# Remove uWSGI if it exists (since we're switching to Gunicorn)
echo "Removing uWSGI..."
apt-get remove --purge -y uwsgi uwsgi-plugin-python3 || true
rm -rf /usr/local/lib/python*/dist-packages/uWSGI* || true
rm -rf /usr/local/bin/uwsgi || true

# Create project directory if not exists
mkdir -p $PROJECT_BASE_PATH
if [ ! -d "$PROJECT_BASE_PATH/.git" ]; then
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
else
    echo "Project already cloned. Pulling latest changes..."
    cd $PROJECT_BASE_PATH
    git pull
fi

# Create virtual environment if not exists
if [ ! -d "$PROJECT_BASE_PATH/env" ]; then
    python3 -m venv $PROJECT_BASE_PATH/env
fi

# Activate virtual environment and install Python packages
source $PROJECT_BASE_PATH/env/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r $PROJECT_BASE_PATH/requirements.txt

# Install Gunicorn (WSGI server)
pip install gunicorn

deactivate  # Exit virtual environment

# Run migrations and collect static files
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput

# Configure Supervisor for Gunicorn
echo "Configuring Supervisor..."
cat <<EOF > /etc/supervisor/conf.d/profiles_api.conf

[program:profiles_api]
command=$PROJECT_BASE_PATH/env/bin/gunicorn --workers 3 --bind unix:$PROJECT_BASE_PATH/profiles_api.sock profiles_project.wsgi:application
directory=$PROJECT_BASE_PATH
autostart=true
autorestart=true
stderr_logfile=/var/log/profiles_api.err.log
stdout_logfile=/var/log/profiles_api.out.log
EOF

supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Configure Nginx
echo "Configuring Nginx..."
cat <<EOF > /etc/nginx/sites-available/profiles_api.conf
server {
    listen 80;
    server_name _;

    location / {
        include proxy_params;
        proxy_pass http://unix:$PROJECT_BASE_PATH/profiles_api.sock;
    }
}
EOF

ln -sf /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "🚀 Deployment completed successfully!"

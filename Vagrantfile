#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Catch pipeline errors

# Project repository URL
PROJECT_GIT_URL='https://github.com/wmbogo12/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

echo "🔍 Detecting installed Python version..."
PYTHON_BIN=$(command -v python3 || command -v python)
if [ -z "$PYTHON_BIN" ]; then
    echo "❌ Python3 is not installed! Installing now..."
    apt-get update
    apt-get install -y python3 python3-venv python3-dev
    PYTHON_BIN=$(command -v python3 || command -v python)
fi
echo "✅ Using Python binary: $PYTHON_BIN"

echo "📦 Installing necessary system dependencies..."
apt-get update
apt-get install -y python3-venv python3-dev python3-pip sqlite3 supervisor nginx git \
                   build-essential libssl-dev libffi-dev python3-setuptools python3-wheel \
                   libpcre3 libpcre3-dev || { echo "❌ Failed to install dependencies"; exit 1; }

# Ensure project directory exists
if [ ! -d "$PROJECT_BASE_PATH" ]; then
    echo "📂 Creating project directory..."
    mkdir -p $PROJECT_BASE_PATH
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
else
    echo "🔄 Project directory exists. Pulling latest changes..."
    cd $PROJECT_BASE_PATH
    git pull
fi

# Create and activate virtual environment
if [ ! -d "$PROJECT_BASE_PATH/env" ]; then
    echo "🐍 Creating Python virtual environment..."
    mkdir -p $PROJECT_BASE_PATH/env
    $PYTHON_BIN -m venv $PROJECT_BASE_PATH/env
fi

# Upgrade pip and install dependencies
echo "⬆️ Upgrading pip and installing requirements..."
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip setuptools wheel
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt || {
    echo "❌ Failed to install Python dependencies";
    exit 1;
}

# Uninstall any existing uWSGI versions before installing a stable one
echo "🚀 Installing uWSGI..."
$PROJECT_BASE_PATH/env/bin/pip uninstall -y uwsgi || true
if ! $PROJECT_BASE_PATH/env/bin/pip install uwsgi==2.0.21; then
    echo "⚠️ uWSGI installation failed! Installing Gunicorn as fallback..."
    $PROJECT_BASE_PATH/env/bin/pip install gunicorn
fi

# Run Django migrations and collect static files
echo "⚙️ Running database migrations and collecting static files..."
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate || { echo "❌ Migration failed"; exit 1; }
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput || echo "⚠️ Static file collection failed"

# Configure Supervisor
if [ -f "$PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf" ]; then
    echo "🔧 Configuring Supervisor..."
    cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
    supervisorctl reread
    supervisorctl update
    supervisorctl restart profiles_api || echo "⚠️ Failed to restart Supervisor process"
else
    echo "⚠️ Supervisor configuration file not found!"
fi

# Configure Nginx
if [ -f "$PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf" ]; then
    echo "🌐 Configuring Nginx..."
    cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
    rm -f /etc/nginx/sites-enabled/default
    ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
    nginx -t && systemctl restart nginx.service || echo "⚠️ Nginx restart failed"
else
    echo "⚠️ Nginx configuration file not found!"
fi

# Set correct permissions
echo "🔑 Setting correct permissions..."
chown -R www-data:www-data $PROJECT_BASE_PATH
chmod -R 755 $PROJECT_BASE_PATH

echo "✅ DEPLOYMENT COMPLETED SUCCESSFULLY! 🚀"
#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Catch pipeline errors

# Project repository URL
PROJECT_GIT_URL='https://github.com/wmbogo12/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

echo "🔍 Detecting installed Python version..."
PYTHON_BIN=$(command -v python3 || command -v python)
if [ -z "$PYTHON_BIN" ]; then
    echo "❌ Python3 is not installed! Installing now..."
    apt-get update
    apt-get install -y python3 python3-venv python3-dev
    PYTHON_BIN=$(command -v python3 || command -v python)
fi
echo "✅ Using Python binary: $PYTHON_BIN"

echo "📦 Installing necessary system dependencies..."
apt-get update
apt-get install -y python3-venv python3-dev python3-pip sqlite3 supervisor nginx git \
                   build-essential libssl-dev libffi-dev python3-setuptools python3-wheel \
                   libpcre3 libpcre3-dev || { echo "❌ Failed to install dependencies"; exit 1; }

# Ensure project directory exists
if [ ! -d "$PROJECT_BASE_PATH" ]; then
    echo "📂 Creating project directory..."
    mkdir -p $PROJECT_BASE_PATH
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
else
    echo "🔄 Project directory exists. Pulling latest changes..."
    cd $PROJECT_BASE_PATH
    git pull
fi

# Create and activate virtual environment
if [ ! -d "$PROJECT_BASE_PATH/env" ]; then
    echo "🐍 Creating Python virtual environment..."
    mkdir -p $PROJECT_BASE_PATH/env
    $PYTHON_BIN -m venv $PROJECT_BASE_PATH/env
fi

# Upgrade pip and install dependencies
echo "⬆️ Upgrading pip and installing requirements..."
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip setuptools wheel
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt || {
    echo "❌ Failed to install Python dependencies";
    exit 1;
}

# Uninstall any existing uWSGI versions before installing a stable one
echo "🚀 Installing uWSGI..."
$PROJECT_BASE_PATH/env/bin/pip uninstall -y uwsgi || true
if ! $PROJECT_BASE_PATH/env/bin/pip install uwsgi==2.0.21; then
    echo "⚠️ uWSGI installation failed! Installing Gunicorn as fallback..."
    $PROJECT_BASE_PATH/env/bin/pip install gunicorn
fi

# Run Django migrations and collect static files
echo "⚙️ Running database migrations and collecting static files..."
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate || { echo "❌ Migration failed"; exit 1; }
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput || echo "⚠️ Static file collection failed"

# Configure Supervisor
if [ -f "$PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf" ]; then
    echo "🔧 Configuring Supervisor..."
    cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
    supervisorctl reread
    supervisorctl update
    supervisorctl restart profiles_api || echo "⚠️ Failed to restart Supervisor process"
else
    echo "⚠️ Supervisor configuration file not found!"
fi

# Configure Nginx
if [ -f "$PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf" ]; then
    echo "🌐 Configuring Nginx..."
    cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
    rm -f /etc/nginx/sites-enabled/default
    ln -s /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
    nginx -t && systemctl restart nginx.service || echo "⚠️ Nginx restart failed"
else
    echo "⚠️ Nginx configuration file not found!"
fi

# Set correct permissions
echo "🔑 Setting correct permissions..."
chown -R www-data:www-data $PROJECT_BASE_PATH
chmod -R 755 $PROJECT_BASE_PATH

echo "✅ DEPLOYMENT COMPLETED SUCCESSFULLY! 🚀"

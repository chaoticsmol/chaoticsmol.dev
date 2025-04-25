#!/bin/bash

# Exit on error
set -e

# Variables
DOMAIN="yourdomain.com"  # Replace with your actual domain
APP_NAME="simple-node-server"
APP_DIR="$(pwd)"
NODE_USER="$(whoami)"
APP_PORT=$(grep -o '"port": [0-9]*' config.json | grep -o '[0-9]*')
NVM_VERSION="0.39.7"  # Latest stable NVM version
NODE_VERSION="lts/*"  # Latest LTS Node.js version

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y nginx certbot python3-certbot-nginx curl git build-essential

# Install NVM and Node.js
echo "Installing NVM and Node.js..."
# Download and install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

# Load NVM (for current script execution)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Install latest LTS Node.js version
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION

# Get the actual installed Node.js version and path
NODE_ACTUAL_VERSION=$(node -v)
NODE_PATH="$NVM_DIR/versions/node/${NODE_ACTUAL_VERSION#v}/bin"

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Configure Nginx
echo "Configuring Nginx..."
sudo tee /etc/nginx/sites-available/$APP_NAME > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Set up SSL with Certbot
echo "Setting up SSL with Certbot..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

# Create SystemD service
echo "Creating SystemD service..."
sudo tee /etc/systemd/system/$APP_NAME.service > /dev/null << EOF
[Unit]
Description=Node.js Application
After=network.target

[Service]
Type=simple
User=$NODE_USER
WorkingDirectory=$APP_DIR
Environment=PATH=$NODE_PATH:$PATH
ExecStart=$NODE_PATH/node $APP_DIR/src/server.js
Restart=on-failure
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$APP_NAME

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable $APP_NAME
sudo systemctl start $APP_NAME

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}Your application is now running at https://$DOMAIN${NC}"
echo -e "${GREEN}Using Node.js version: $NODE_ACTUAL_VERSION${NC}"
echo ""
echo "Commands you might need:"
echo "  - Check service status: sudo systemctl status $APP_NAME"
echo "  - View logs: sudo journalctl -u $APP_NAME"
echo "  - Restart service: sudo systemctl restart $APP_NAME"
echo ""
echo "Important: Remember to:"
echo "  1. Update the DOMAIN variable in this script with your actual domain"
echo "  2. Make sure your domain's DNS records point to this server" 
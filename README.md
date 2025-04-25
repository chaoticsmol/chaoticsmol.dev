# Simple NodeJS Static Server with Installation Script

A minimalist NodeJS application that serves static HTML and CSS files.

## Server Setup

1. Install dependencies:
   ```
   npm install
   ```

2. Start the server:
   ```
   npm start
   ```

3. Open your browser and navigate to:
   ```
   http://localhost:3000
   ```

## Files

- `server.js` - Express server configuration
- `public/index.html` - HTML file served by the application
- `public/main.css` - CSS styles for the HTML file

## Production Deployment

This repository includes an installation script that automates the setup of:
- Nginx as a reverse proxy
- SSL certificates with Certbot
- HTTPS configuration
- SystemD service for automatic restarts
- NVM (Node Version Manager) with the latest stable Node.js version

### Prerequisites

- Ubuntu server (18.04 or newer)
- A domain name pointing to your server
- Root or sudo access

### Installation

1. Clone this repository to your server
2. Edit the `install.sh` file to update the `DOMAIN` variable with your domain name
3. Make the script executable:
   ```
   chmod +x install.sh
   ```
4. Run the installation script:
   ```
   ./install.sh
   ```

### What the Script Does

1. Installs Nginx, Certbot, and other required dependencies
2. Installs NVM (Node Version Manager)
3. Uses NVM to install the latest stable Node.js LTS version
4. Configures Nginx as a reverse proxy to your Node.js application
5. Obtains SSL certificates from Let's Encrypt
6. Configures HTTPS
7. Creates a SystemD service for your application
8. Enables and starts the service

### SystemD Service Management

After installation, you can manage your application with these commands:

- Check status: `sudo systemctl status simple-node-server`
- View logs: `sudo journalctl -u simple-node-server`
- Restart: `sudo systemctl restart simple-node-server`
- Stop: `sudo systemctl stop simple-node-server`
- Start: `sudo systemctl start simple-node-server`

### Manual Configuration

If you need to modify the configuration:

- Nginx configuration: `/etc/nginx/sites-available/simple-node-server`
- SystemD service: `/etc/systemd/system/simple-node-server.service`

After modifying the Nginx configuration, run:
```
sudo nginx -t && sudo systemctl reload nginx
```

After modifying the SystemD service, run:
```
sudo systemctl daemon-reload
``` 
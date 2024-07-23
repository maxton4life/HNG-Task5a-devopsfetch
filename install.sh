#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package list
sudo apt update

# Check and install ss if not installed
if command_exists ss; then
    echo "ss is already installed"
else
    echo "Installing ss..."
    sudo apt install -y iproute2
fi

# Check and install Docker if not installed
if command_exists docker; then
    echo "Docker is already installed"
else
    echo "Installing Docker..."
    sudo apt install -y docker.io
fi

# Check and install Nginx if not installed
if command_exists nginx; then
    echo "Nginx is already installed"
else
    echo "Installing Nginx..."
    sudo apt install -y nginx
fi

# Check and install jq if not installed (for JSON parsing in Docker details)
if command_exists jq; then
    echo "jq is already installed"
else
    echo "Installing jq..."
    sudo apt install -y jq
fi

# Copy the devopsfetch script to /usr/local/bin
echo "Copying devopsfetch script to /usr/local/bin..."
sudo cp devopsfetch.sh /usr/local/bin/devopsfetch
sudo chmod +x /usr/local/bin/devopsfetch

# Create a systemd service for devopsfetch
echo "Creating systemd service for devopsfetch..."
cat <<EOL | sudo tee /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOpsFetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the systemd service
echo "Enabling and starting the devopsfetch service..."
sudo systemctl enable devopsfetch
sudo systemctl start devopsfetch

# Set up logrotate configuration
echo "Setting up logrotate configuration..."
sudo mkdir -p /etc/logrotate.d
sudo cp logrotate/devopsfetch /etc/logrotate.d/devopsfetch

echo "Installation complete."

# DevOpsFetch

## Description

DevOpsFetch is a Bash script designed to retrieve and monitor system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses. It also supports continuous monitoring and logging as a systemd service.

## Features

- **Ports Information:**
  - Display all active ports and services.
  - Provide detailed information about a specific port.
  
- **Docker Information:**
  - List all Docker images and containers.
  - Provide detailed information about a specific container.
  
- **Nginx Information:**
  - Display all Nginx domains and their ports.
  - Provide detailed configuration information for a specific domain.
  
- **Users Information:**
  - List all users and their last login times.
  - Provide detailed information about a specific user.
  
- **Time Range Filtering:**
  - Display activities within a specified time range.
  
- **Continuous Monitoring:**
  - Set up as a systemd service for continuous monitoring and logging.

## Installation

Run the following script to install necessary dependencies, copy the `devopsfetch` script to a suitable location, and set up a systemd service:

```bash
sudo bash install.sh
```

#!/bin/bash

# Function to display help
display_help() {
    cat << EOF
Usage: devopsfetch [OPTION]... [ARGUMENT]...
Retrieve and display server information.

Options:
  -p, --port [PORT]       Display active ports or info about a specific port
  -d, --docker [CONTAINER] List Docker images/containers or info about a specific container
  -n, --nginx [DOMAIN]    Display Nginx domains or config for a specific domain
  -u, --users [USER]      List users and last login times or info about a specific user
  -t, --time START END    Display activities within a specified time range
  -h, --help              Display this help message

Examples:
  devopsfetch -p                  # List all active ports
  devopsfetch -p 80               # Show details for port 80
  devopsfetch -d                  # List all Docker images and containers
  devopsfetch -d mycontainer      # Show details for 'mycontainer'
  devopsfetch -n                  # List all Nginx domains
  devopsfetch -n example.com      # Show Nginx config for example.com
  devopsfetch -u                  # List all users and last login times
  devopsfetch -u ChukwumaAdekunle # Show details for user 'ChukwumaAdekunle'
  devopsfetch -t '2023-01-01 00:00:00' '2023-01-31 23:59:59'  # Show activities in January 2023
EOF
}

# Function to format output as a table
format_table() {
    column -t -s $'\t'
}

# Function to display port information
display_ports() {
    if [ -z "$1" ]; then
        # List all active ports and services
        echo "Active Ports and Services:"
        ss -tuln | awk 'NR>1 {print $5}' | awk -F: '{print $NF}' | sort -n | uniq | \
        while read -r port; do
            service=$(lsof -i :"$port" | awk 'NR==2 {print $1}')
            echo -e "$port\t$service"
        done | format_table
    else
        # Show details for a specific port
        echo "Details for port $1:"
        lsof -i :"$1"
    fi
}

# Function to display Docker information
display_docker() {
    if [ -z "$1" ]; then
        # List all Docker images and containers
        echo "Docker Images:"
        docker images | format_table
        echo
        echo "Docker Containers:"
        docker ps -a | format_table
    else
        # Show details for a specific container
        echo "Details for container $1:"
        docker inspect "$1" | jq '.[0] | {Id, Name, State, Image, Mounts}'
    fi
}

# Function to display Nginx information
display_nginx() {
    if [ -z "$1" ]; then
        # List all Nginx domains and ports
        echo "Nginx Domains and Ports:"
        grep -R server_name /etc/nginx/sites-enabled/ | awk '{print $2}' | sed 's/;//' | \
        while read -r domain; do
            port=$(grep -R "listen " /etc/nginx/sites-enabled/ | grep -v "#" | awk '{print $2}' | sed 's/;//' | head -1)
            echo -e "$domain\t$port"
        done | format_table
    else
        # Show Nginx configuration for a specific domain
        echo "Nginx configuration for $1:"
        grep -R -A 20 "server_name $1" /etc/nginx/sites-enabled/
    fi
}

# Function to display user information
display_users() {
    if [ -z "$1" ]; then
        # List all users and their last login times
        echo "Users and Last Login Times:"
        last -w | awk '!seen[$1]++ {print $1, $3, $4, $5, $6}' | format_table
    else
        # Show details for a specific user
        echo "Details for user $1:"
        id "$1"
        echo "Last login:"
        last "$1" | head -1
    fi
}

# Function to display activities within a time range
display_time_range() {
    echo "Activities between $1 and $2:"
    journalctl --since "$1" --until "$2" | tail -n 50
}

# Main script logic to handle command-line arguments
main() {
    case "$1" in
        -p|--port)
            display_ports "$2"
            ;;
        -d|--docker)
            display_docker "$2"
            ;;
        -n|--nginx)
            display_nginx "$2"
            ;;
        -u|--users)
            display_users "$2"
            ;;
        -t|--time)
            display_time_range "$2" "$3"
            ;;
        -h|--help)
            display_help
            ;;
        *)
            echo "Invalid option. Use -h or --help for usage information."
            exit 1
            ;;
    esac
}

# Execute the main function with the provided arguments
main "$@"

#!/bin/bash

# Read input
read -p "Enter domain name: " DOMAIN_NAME
read -p "Enter FTP username: " FTP_USER

# Set variables
DOCUMENT_ROOT="/var/www/$DOMAIN_NAME"

# Check if Apache is installed
if command -v apache2 >/dev/null 2>&1; then
    # Check if Nginx is installed
    if command -v nginx >/dev/null 2>&1; then
        # Prompt for virtual host selection
        read -p "Both Apache and Nginx are installed. Enter 'apache' or 'nginx' to specify the virtual host to remove: " WEBSERVER

        # Remove Apache virtual host configuration
        if [ "$WEBSERVER" = "apache" ]; then
            if [ -f "/etc/apache2/sites-available/$DOMAIN_NAME.conf" ]; then
                a2dissite $DOMAIN_NAME.conf
                rm /etc/apache2/sites-available/$DOMAIN_NAME.conf
                echo "Apache virtual host configuration removed for domain: $DOMAIN_NAME"
                service apache2 reload
            else
                echo "No Apache virtual host configuration found for domain: $DOMAIN_NAME"
            fi
        elif [ "$WEBSERVER" = "nginx" ]; then
            # Remove Nginx virtual host configuration
            if [ -f "/etc/nginx/sites-available/$DOMAIN_NAME" ]; then
                rm /etc/nginx/sites-available/$DOMAIN_NAME
                rm /etc/nginx/sites-enabled/$DOMAIN_NAME
                echo "Nginx virtual host configuration removed for domain: $DOMAIN_NAME"
                service nginx reload
            else
                echo "No Nginx virtual host configuration found for domain: $DOMAIN_NAME"
            fi
        else
            echo "Invalid web server selection."
            exit 1
        fi
    else
        # Remove Apache virtual host configuration
        if [ -f "/etc/apache2/sites-available/$DOMAIN_NAME.conf" ]; then
            a2dissite $DOMAIN_NAME.conf
            rm /etc/apache2/sites-available/$DOMAIN_NAME.conf
            echo "Apache virtual host configuration removed for domain: $DOMAIN_NAME"
            service apache2 reload
        else
            echo "No Apache virtual host configuration found for domain: $DOMAIN_NAME"
        fi
    fi
else
    echo "Apache is not installed."
fi

# Check if Nginx is installed
if command -v nginx >/dev/null 2>&1; then
    # Remove Nginx virtual host configuration
    if [ -f "/etc/nginx/sites-available/$DOMAIN_NAME" ]; then
        rm /etc/nginx/sites-available/$DOMAIN_NAME
        rm /etc/nginx/sites-enabled/$DOMAIN_NAME
        echo "Nginx virtual host configuration removed for domain: $DOMAIN_NAME"
        service nginx reload
    else
        echo "No Nginx virtual host configuration found for domain: $DOMAIN_NAME"
    fi
else
    echo "Nginx is not installed."
fi

# Remove FTP user and home directory
if id -u $FTP_USER >/dev/null 2>&1; then
    userdel -r $FTP_USER >/dev/null 2>&1
    echo "FTP user and home directory removed: $FTP_USER"
else
    echo "FTP user does not exist: $FTP_USER"
fi

# Display completion message
echo "Cleanup completed."
#!/bin/bash
HOSTS_FILE="/etc/hosts"
CHROOT_FILE= "/etc/vsftpd.chroot_list"
# Read input
read -p "Enter domain name: " DOMAIN_NAME
read -p "Enter FTP username: " FTP_USER
read -s -p "Enter FTP password: " FTP_PASSWORD
echo

# Set variables
DOCUMENT_ROOT="/var/www/$DOMAIN_NAME"

# Function to remove created configurations
cleanup() {
    echo "Cleaning up..."
    
    # Remove virtual host configuration
    if [ -f "/etc/apache2/sites-available/$DOMAIN_NAME.conf" ]; then
        a2dissite $DOMAIN_NAME.conf
        rm /etc/apache2/sites-available/$DOMAIN_NAME.conf
    fi
    
    if [ -f "/etc/nginx/sites-available/$DOMAIN_NAME" ]; then
        rm /etc/nginx/sites-available/$DOMAIN_NAME
        rm /etc/nginx/sites-enabled/$DOMAIN_NAME
    fi
    
    # Remove FTP user and home directory
    userdel -r $FTP_USER >/dev/null 2>&1
    
    echo "Script execution failed."
}

trap cleanup ERR
# Check if vsftpd is installed
if ! command -v vsftpd >/dev/null 2>&1; then
    echo "vsftpd is not installed. Installing vsftpd..."
    apt-get update
    apt-get install vsftpd -y
fi

# Check if Apache and Nginx are both installed
if command -v apache2 >/dev/null 2>&1 && command -v nginx >/dev/null 2>&1; then
    read -p "Both Apache and Nginx are installed. Please select the web server you want to configure (apache2/nginx): " WEB_SERVER
    if [[ "$WEB_SERVER" != "apache2" && "$WEB_SERVER" != "nginx" ]]; then
        echo "Invalid web server selection. Exiting..."
        exit 1
    fi
elif command -v apache2 >/dev/null 2>&1; then
    WEB_SERVER="apache2"
elif command -v nginx >/dev/null 2>&1; then
    WEB_SERVER="nginx"
else
    echo "Neither Apache nor Nginx is installed. Please install one of them."
    exit 1
fi

# Create document root directory if it doesn't exist
if [ ! -d "$DOCUMENT_ROOT" ]; then
    mkdir -p "$DOCUMENT_ROOT"
fi

# Create index.html file for testing
echo "<h1>Testing $DOMAIN_NAME</h1>" > "$DOCUMENT_ROOT/index.html"


# Configure selected web server
if [ "$WEB_SERVER" = "apache2" ]; then
    # Install Apache if not already installed
    if ! command -v apache2 >/dev/null 2>&1; then
    echo "Apache is not installed. Installing Apache..."
    apt-get update
    apt-get install apache2 -y
    else
    echo "Apache is already installed."
    fi
    # Create virtual host configuration
    cat <<EOF > /etc/apache2/sites-available/$DOMAIN_NAME.conf
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    DocumentRoot $DOCUMENT_ROOT
    ErrorLog \${APACHE_LOG_DIR}/{$DOMAIN_NAME}-error.log
    CustomLog \${APACHE_LOG_DIR}/{$DOMAIN_NAME}-access.log combined
</VirtualHost>
EOF

    # Enable the virtual host
    a2ensite $DOMAIN_NAME.conf
    service apache2 reload

elif [ "$WEB_SERVER" = "nginx" ]; then
    # Install Nginx if not already installed
    if ! command -v nginx >/dev/null 2>&1; then
    echo "Nginx is not installed. Installing Nginx..."
    apt-get update
    apt-get install nginx -y
    else
    echo "nginx is already installed."
    fi
    # Create virtual host configuration
    cat <<EOF > /etc/nginx/sites-available/$DOMAIN_NAME
server {
    listen 80;
    server_name $DOMAIN_NAME;

    location / {
        root $DOCUMENT_ROOT;
        index index.html index.htm;
    }
}
EOF

    # Enable the virtual host
    ln -s /etc/nginx/sites-available/$DOMAIN_NAME /etc/nginx/sites-enabled/
    service nginx reload
fi

# Check if FTP user or domain directory exists
if id -u $FTP_USER >/dev/null 2>&1; then
    echo "FTP user already exists: $FTP_USER"
else
    # Create FTP user
    useradd $FTP_USER -d $DOCUMENT_ROOT -s /bin/bash
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
    echo "FTP user created: $FTP_USER"
    echo "FTP user password: $FTP_PASSWORD"
    # Grant ownership to the FTP user
    chown -R $FTP_USER:$FTP_USER "$DOCUMENT_ROOT"
fi

# Configure vsftpd
VSFTPD_CONF="/etc/vsftpd.conf"
VSFTPD_CONFIG=$(cat <<EOF
listen=NO
listen_ipv6=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=45000
userlist_enable=YES
userlist_file=/etc/vsftpd.chroot_list
userlist_deny=NO
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
EOF
)

# Check if vsftpd.conf exists
if [ -f "$VSFTPD_CONF" ]; then
    # Check if the configuration is already present
    if grep -Fxq "$VSFTPD_CONFIG" "$VSFTPD_CONF"; then
        echo "vsftpd configuration already exists."
    else
        echo "$VSFTPD_CONFIG" >> "$VSFTPD_CONF"
        echo "vsftpd configuration added."
    fi
else
    echo "$VSFTPD_CONFIG" > "$VSFTPD_CONF"
    echo "vsftpd configuration file created."
fi

if grep -q "$FTP_USER" "$CHROOT_FILE"; then
    echo "Entry already exists in hosts file: $FTP_USER"
else
    # Append entry to hosts file
    echo "$FTP_USER" | sudo tee -a "$CHROOT_FILE"
    echo "Entry appended to hosts file: $FTP_USER"
fi

systemctl restart vsftpd

# Check if entry already exists in hosts file
if grep -q "$DOMAIN_NAME" "$HOSTS_FILE"; then
    echo "Entry already exists in hosts file: $DOMAIN_NAME"
else
    # Append entry to hosts file
    echo "127.0.0.1    $DOMAIN_NAME" | sudo tee -a "$HOSTS_FILE"
    echo "Entry appended to hosts file: $DOMAIN_NAME"
fi
trap cleanup ERR
# Display information
echo "FTP user and virtual host configuration completed for domain: $DOMAIN_NAME"
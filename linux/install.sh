#!/bin/bash

# Define variables
URL="inventory.gov.supersim.com.br"
FOLDER="/etc/ocsinventory-agent"
VERSION="2.10.2"
AGENT_URL="https://github.com/OCSInventory-NG/UnixAgent/releases/download/v$VERSION/Ocsinventory-Unix-Agent-$VERSION.tar.gz"
CERT_FILE="$FOLDER/cacert.pem"
GREEN_BOLD="\e[92m"
RED_BOLD="\e[31m"
RESET_COLOR="\e[0m"

# Remove previous installation
printf "\n Removing previous installation... \n"
sudo apt purge -y ocsinventory-agent
sudo rm -rf /etc/apt/trusted.gpg.d/ocs* /etc/apt/sources.list.d/ocs* /var/log/ocsinventory-agent.log \
            /var/lib/ocsinventory-agent /etc/ocsinventory-agent /etc/cron.d/ocsinventory* \
            /usr/local/bin/ocsinventory* /opt/ocsinventory-agent

# Install required dependencies
printf "\n Installing dependencies... \n"
sudo apt update
sudo apt install -y perl make curl libmodule-install-perl dmidecode libxml-simple-perl \
  libcompress-zlib-perl libnet-ip-perl libwww-perl libdigest-md5-perl libdata-uuid-perl \
  libcrypt-ssleay-perl libnet-snmp-perl libproc-pid-file-perl libproc-daemon-perl \
  net-tools libsys-syslog-perl pciutils smartmontools read-edid nmap libnet-netmask-perl \
  libregexp-ipv6-perl

# Download and install the agent
printf "\n Downloading and installing the agent... \n"
sudo wget -P $FOLDER $AGENT_URL

# Copy files and set permissions
sudo cp ./cron/* /etc/cron.d/
sudo cp ./config/* $FOLDER
sudo chmod +x $FOLDER/certificate.sh

# Download the certificate
printf "\n Downloading the certificate... \n"
openssl s_client -showcerts -connect $URL:443 </dev/null 2>/dev/null | openssl x509 -outform PEM >$CERT_FILE

#Setting asset ID
printf "$GREEN_BOLD \n Input asset ID \n $RESET_COLOR"
read TAG
printf "$RED_BOLD \n Recording asset $TAG... \n $RESET_COLOR"
sudo sed -i "s@tag=@tag=$TAG@g" /etc/ocsinventory-agent/ocsinventory-agent.cfg

# Extract and compile the agent
printf "\n Installing the agent... \n"
sudo tar -xvzf $FOLDER/Ocsinventory-Unix-Agent-$VERSION.tar.gz -C $FOLDER
cd $FOLDER/Ocsinventory-Unix-Agent-$VERSION
sudo perl Makefile.PL
sudo make 
(
  # Do you want to configure the agent?
  echo ""
  # Should the old unix_agent settings be imported?
  echo ""
  # What is the address of your ocs server?> [https://inventory.gov.supersim.com.br/ocsinventory]        
  echo ""
  # Do you need credential for the server? (You probably don't)
  echo ""
  # Do yo want to install the cron task in /etc/cron.d?
  echo ""
  # Where do you want the agent to store its files? (You probably don't need to change it)?> [/var/lib/ocsinventory-agent]
  echo ""
  # Should I remove the old unix_agent?
  echo ""
  # Do you want disable SSL CA verification configuration option (not recommended)?
  echo ""
  # Do you want disable software inventory?
  echo ""
  # Do you want to use OCS-Inventory software deployment feature?
  echo ""
  # Do you want to send an inventory of this machine?
  echo ""
) | sudo make install

printf "\n Installation completed. \n"
sudo rm $FOLDER/Ocsinventory-Unix-Agent-$VERSION.tar.gz
exit 0

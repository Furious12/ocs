#!/bin/bash

URL="inventory.gov.supersim.com.br"
FOLDER="/etc/ocsinventory-agent"
CERT_FILE="$FOLDER/cacert.pem"

openssl s_client -showcerts -connect $URL:443 </dev/null 2>/dev/null | openssl x509 -outform PEM >$CERT_FILE

exit 0
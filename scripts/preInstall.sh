#!/usr/bin/env bash
#set env vars
set -o allexport; source .env; set +o allexport;


TOLGEE_AUTHENTICATION_JWT_SECRET=$(openssl rand -base64 24 | tr -d '\n' ; echo)

cat <<EOT > ./servers.json
{
    "Servers": {
        "1": {
            "Name": "local",
            "Group": "Servers",
            "Host": "db",
            "Port": 45613,
            "MaintenanceDB": "postgres",
            "SSLMode": "prefer",
            "Username": "postgres",
            "PassFile": "/pgpass"
        }
    }
}
EOT

cat /opt/elestio/startPostfix.sh > post.txt
filename="./post.txt"

SMTP_LOGIN=""
SMTP_PASSWORD=""

# Read the file line by line
while IFS= read -r line; do
  # Extract the values after the flags (-e)
  values=$(echo "$line" | grep -o '\-e [^ ]*' | sed 's/-e //')

  # Loop through each value and store in respective variables
  while IFS= read -r value; do
    if [[ $value == RELAYHOST_USERNAME=* ]]; then
      SMTP_LOGIN=${value#*=}
    elif [[ $value == RELAYHOST_PASSWORD=* ]]; then
      SMTP_PASSWORD=${value#*=}
    fi
  done <<< "$values"

done < "$filename"

rm post.txt

cat << EOT >> ./.env

TOLGEE_AUTHENTICATION_JWT_SECRET=${TOLGEE_AUTHENTICATION_JWT_SECRET}
TOLGEE_SMTP_AUTH=true
TOLGEE_SMTP_FROM=Tolgee <${SMTP_LOGIN}>
TOLGEE_SMTP_HOST=tuesday.mxrouting.net
TOLGEE_SMTP_PORT=465
TOLGEE_SMTP_PASSWORD=${SMTP_PASSWORD}
TOLGEE_SMTP_USERNAME=${SMTP_LOGIN}
TOLGEE_SMTP_SSL_ENABLED=true
EOT
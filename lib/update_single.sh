#!/bin/sh
#
# Create or renew certificates for a single domain
#

## Die on errors and load our utils
set -e
. "./lib/utils.sh"


## Inputs
cert_file="$1"
if [ -z "$cert_file" ] ; then
  echo "Usage: ./bin/update_single.sh certificate_spec_file"
  exit 2
fi

cert_name=`basename "$cert_file"`
echo "*** Updating '$cert_name' certificate"
printf "*** at "
date


## Check to see if we have a valid domain to update

if [ -e "$cert_file" ] ; then
  echo "... reading certificate '$cert_name' spec file"
  . "$cert_file"
fi

exit_if_disabled "FATAL: certificate '$cert_name' disabled on the local $cert_file"

if [ -z "$DOMAIN" ] ; then
  fatal "no domain to update on certificate '$cert_name'" "local $cert_file lacks a DOMAIN configuration"
fi


## Check for other required settings
for cfvar in "CLOUDFLARE_EMAIL" "CLOUDFLARE_API_KEY" "EMAIL" "KEY_TYPE"; do
  if [ -z "${!cfvar}" ] ; then
    fatal "missing $cfvar definition" "add it to the global or local $cert_file"
  fi
done
export CLOUDFLARE_EMAIL CLOUDFLARE_API_KEY


## Check for lego
printf "... using "
lego --version


## Production or Staging?
server=""
if [ "$ENVIRONMENT" = "production" ] ; then
  echo "... using **Production** environment"
else
  server="--server https://acme-staging.api.letsencrypt.org/directory"
  echo "... using Staging environment"
fi


## Create or renew?

if [ -e "certificates/$DOMAIN.key" -a -e "certificates/$DOMAIN.crt" -a -e "certificates/$DOMAIN.json" ] ; then
  ## Renew the certificate!
  echo "... renewing the certificate for domain '$DOMAIN'"
  set -x
  lego \
        --path "." \
        --email="$EMAIL" \
        --domains="$DOMAIN" \
        --dns cloudflare \
        --key-type "$KEY_TYPE" \
        --accept-tos \
        $server renew
  set +x
else    
  ## Create the certificate!
  echo "... creating certificate for domain '$DOMAIN'"
  set -x
  lego \
      --path "." \
      --email="$EMAIL" \
      --domains="$DOMAIN" \
      --dns cloudflare \
      --key-type "$KEY_TYPE" \
      --accept-tos \
      $server run
  set +x
fi

if [ ! -e "certificates/$DOMAIN.key" -o ! -e "certificates/$DOMAIN.crt" -o ! -e "certificates/$DOMAIN.json" ] ; then
  fatal "failed to create certificate for '$DOMAIN'"
fi

git_commit_globals
git_commit "Updated certificate $cert for domain $DOMAIN" "$cert_file" "./certificates/$DOMAIN.*"
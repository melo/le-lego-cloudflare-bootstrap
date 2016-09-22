#!/bin/bash
#
# Create or renew certificates for a single domain
#

## Die on errors and load our utils
set -e
. "./lib/utils.sh"


## Inputs
cert_spec_dir="$1"
if [ -z "$cert_spec_dir" ] ; then
  echo "Usage: ./lib/update_single.sh certificate_spec_dir"
  exit 2
fi

cert_name=`basename "$cert_spec_dir"`
echo "*** Updating '$cert_name' certificate"
printf "*** at "
date


## Check to see if we have a valid domain to update
cert_spec_file="$cert_spec_dir/spec.sh"
if [ -e "$cert_spec_file" ] ; then
  echo "... reading certificate '$cert_spec_file' spec file"
  . "$cert_spec_file"
fi

fatal_if_disabled "certificate '$cert_name' disabled in '$cert_spec_file' spec file"

if [ -z "$DOMAIN" ] ; then
  DOMAIN="$cert_name"
  echo "... using certificate spec directory name as domain, '$DOMAIN'"
fi

if [ -z "$DOMAIN" ] ; then
  fatal "no domain to use on certificate '$cert_name' spec file" "local $cert_spec_file lacks a DOMAIN configuration"
fi

## Check for other required settings

for var in "EMAIL" "CLOUDFLARE_EMAIL" "CLOUDFLARE_API_KEY" "RENEW_DAYS_BEFORE_EXPIRE" "KEY_TYPE" "ENVIRONMENT" ; do
  if [ -z "${!var}" ] ; then
    fatal "missing $var definition via spec files" "add it to the global or local '$cert_name' certificate spec file"
  fi
done
export CLOUDFLARE_EMAIL CLOUDFLARE_API_KEY


## Check for lego: this will die if lego not found
printf "... using "
lego --version


## Production or Staging?
server=""
if [ "$ENVIRONMENT" = "production" ] ; then
  echo "... using **production** environment"
elif [ "$ENVIRONMENT" = "staging" ] ; then
  server="--server https://acme-staging.api.letsencrypt.org/directory"
  echo "... using staging environment"
else
  fatal "environment '$ENVIRONMENT' not recognized" "valid values are 'production' and 'staging'"
fi


## Define all the domains to generate cert for
echo "... generating certificate for domain '$DOMAIN'"
domains="--domains $DOMAIN"
extra_domains_file="$cert_spec_dir/extra-domains.txt"
if [ -e "$extra_domains_file" ] ; then
  echo "... scanning file $extra_domains_file for extra domains"
   while read dom ; do
    echo "...... adding extra domain '$dom'"
    domains+=" --domains $dom"
  done < <( egrep -v "^\s*#" "$extra_domains_file" | egrep -v "^\s*$" )
else
  echo "... extra domains file '$extra_domains_file' not found, skipping"
fi


## Create or renew?
if [ -e "certificates/$DOMAIN.key" -a -e "certificates/$DOMAIN.crt" -a -e "certificates/$DOMAIN.json" ] ; then
  ## Renew the certificate!
  echo "... renewing the certificate '$cert_name'"
  dry_run lego \
        --path "." \
        --email="$EMAIL" \
        $domains \
        --dns cloudflare \
        --key-type "$KEY_TYPE" \
        --accept-tos \
        $server renew \
        --days "$RENEW_DAYS_BEFORE_EXPIRE"
else
  ## Create the certificate!
  echo "... creating certificate '$cert_name'"
  dry_run lego \
      --path "." \
      --email="$EMAIL" \
      $domains \
      --dns cloudflare \
      --key-type "$KEY_TYPE" \
      --accept-tos \
      $server run
fi

if [ ! -e "certificates/$DOMAIN.key" -o ! -e "certificates/$DOMAIN.crt" -o ! -e "certificates/$DOMAIN.json" ] ; then
  dry_run fatal "failed to create certificate for '$DOMAIN'"
fi


## commit all the things
git_commit_globals
git_commit_and_mark_dirty ".dirty.single" "Updated certificate $cert for domain $DOMAIN" "$cert_file" "./certificates/$DOMAIN."*

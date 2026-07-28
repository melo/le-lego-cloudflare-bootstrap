#
# Global configuration file
#
# All commented variables have the default value set
# To change, uncomment and update the value
#

##### Required configuration section

## Your email address (required)
## Used for warning messages about certificate expiration
EMAIL=""

## Your DNS Provider configuration environment
##
## Use "lego dnshelp" to figure out what you need
##
## You do need a PROVIDER though...
##
# PROVIDER=cloudflare
# PROVIDER=route53

## Your provider credentials (API keys/tokens) are SECRETS and must NOT live in
## this file, which is committed to git. Put them in a gitignored ./.env instead:
## it is sourced and auto-exported below so lego picks them up. See .env.example.
##
## Run "lego dnshelp -c $PROVIDER" to see exactly which variables your provider
## needs, e.g.:
##   CloudFlare (scoped token, recommended): CLOUDFLARE_DNS_API_TOKEN
##   CloudFlare (legacy global key):         CLOUDFLARE_EMAIL + CLOUDFLARE_API_KEY
##   AWS Route53:                            AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY
if [ -e "./.env" ] ; then
  set -a          # auto-export everything defined in .env, so lego can read it
  . "./.env"
  set +a
fi


##### Operations flags section

## How many days to expiration date for renewal to happen, default is 30
# RENEW_DAYS_BEFORE_EXPIRE=30

## Should we commit important files automatically
## Set to "no" if you don't want automatic commits with all the changes
# GIT_COMMITS="yes"

## Dry run: don't commit or execute lego commands
## Usefull to understand what would happen
# DRY_RUN="no"

## Disable all the updates
## Set to "yes this will make ./bin/update.sh stop working. Useful to
## make sure nobody updates nothing, even automated scripts
# DISABLED="no"

## Use staging or production environment?
## Uncomment the next line to use production. I *strongly* recommend that you do this *per* certificate...
# ENVIRONMENT="production"


##### Certificate defaults section

## Type of key to create for certificate, *not* the account key
## The default is the most widely supported type by the majority of
## browsers, rsa2048
## Supported: rsa2048, rsa4096, rsa8192, ec256, ec384
# KEY_TYPE="rsa2048"

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

## Example: for CloudFlare, define the CloudFlare login and API Key
## to use. We default CLOUDFLARE_EMAIL to EMAIL, saves some typing
## on simple setups :)
# CLOUDFLARE_EMAIL="$EMAIL"
# CLOUDFLARE_API_KEY=""

## Example: for AWS Route53, we need AWS_* variables.
## We do recommend that you use aws-keychain
## to keep your credentials safe
# AWS_ACCESS_KEY_ID=...
# AWS_SECRET_ACCESS_KEY=...


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
# ENVIRONMENT="staging"


##### Certificate defaults section

## Type of key to create for certificate, *not* the account key
## The default is the most widely supported type by the majority of
## browsers, rsa2048
## Supported: rsa2048, rsa4096, rsa8192, ec256, ec384
# KEY_TYPE="rsa2048"

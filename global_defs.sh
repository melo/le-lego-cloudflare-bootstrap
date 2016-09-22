#
# Global configuration file
#

##### Required configuration section

## Your email address (required)
## Used for warning messages about certificate expiration
EMAIL=""

## Define the CloudFlare login and API Key to use
CLOUDFLARE_EMAIL="$EMAIL"
CLOUDFLARE_API_KEY=""


##### Operations flags section

## Set to "no" if you don't want automatic commits with all the changes
GIT_COMMITS="yes"

## Uncomment the next line if you want to disable all updates to all domains
# DISABLED="yes"

## Use staging or production environment? (defaults to staging)
## Uncomment the next line to use production. I *strongly* recommend that you do this *per* certificate...
# ENVIRONMENT="production"


##### Certificate defaults section

## Type of key to create for certificate
## The default is the most widely supported type
## Supported: rsa2048, rsa4096, rsa8192, ec256, ec384
KEY_TYPE="rsa2048"

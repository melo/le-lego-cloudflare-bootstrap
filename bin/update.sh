#!/bin/bash
#
# Create or renew certificates for a set of domains
#

## location of certificates directories
certs_dir="./certificates_specs"


## Die on errors and load our utils
set -e
. "./lib/utils.sh"


## Which certificates to update?
certs="$@"
git_commit_globals
if [ -z "$certs" ] ; then
  ls -1 "$certs_dir/"*.sh | while read cert_file ; do
    update_single_cert "$cert_file"
  done
else
  for cert_file in "$@" ; do
    update_single_cert "$cert_file"
  done
fi




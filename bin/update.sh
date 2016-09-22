#!/bin/bash
#
# Create or renew certificates for a set of domains
#

## location of certificates speficiations
specs_dir="./specs"


## Die on errors and load our utils
set -e
. "./lib/utils.sh"


## Which certificates to update?
specs="$@"
git_commit_globals

rm -f ".dirty.at_least_one"
if [ -z "$specs" ] ; then
  ls -d1 "$specs_dir/"* | while read spec_dir ; do
    if [ -d "$spec_dir" ] ; then
      update_single_cert "$spec_dir"
    fi
  done
else
  for cert_dir in "$@" ; do
    if [ -d "$cert_dir" ] ; then
      update_single_cert "$cert_dir"
    else
      fatal "invalid certificate spec directory, '$cert_dir', not a directory";
    fi
  done
fi


## Run deploy hook
if [ -e ".dirty.at_least_one" ] ; then
  rm -f ".dirty.at_least_one"
  if [ -x "./hooks/deploy.sh" ] ; then
    echo "... running deploy hook"
    ./hooks/deploy.sh
  fi
fi


## Finito
echo "... update completed"

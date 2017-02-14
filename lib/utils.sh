#
# Our shell utilities library and bootstrap code
#

#################
# Generic helpers

fatal ()
{
  echo "FATAL: $1"
  if [ -n "$2" ] ; then
    echo "       $2"
  fi
  exit 1
}

if_true ()
{
  local var
  var="$1"
  shift
  if [ "${!var}" = 1 -o "${!var}" = "yes" ] ; then
    "$@"
  fi
}

if_false ()
{
  local var
  var="$1"
  shift
  if [ "${!var}" = 0 -o "${!var}" = "no" ] ; then
    "$@"
  fi
}

dry_run ()
{
  if_false 'DRY_RUN' "$@"
  if_true  'DRY_RUN' echo "!!! Dry run:" "$@"
}

fatal_if_disabled ()
{
  if_true "DISABLED" fatal "$@"
}


#############
# Git helpers

_do_git_commit () {
  local msg
  msg="$1"
  shift

  if [ -n "$( git status --porcelain "$@" )" ] ; then
    echo "... git commit '$msg' of '$@'"
    dry_run git add "$@"
    dry_run git commit -m "$msg" -m "Generated-by: le-lego-$PROVIDER $0"
  fi
}

git_commit ()
{
  if_true "GIT_COMMITS" _do_git_commit "$@"
}

_do_git_commit_and_mark_dirty () {
  local msg flag
  flag="$1"
  shift
  msg="$1"
  shift

  if [ -n "$( git status --porcelain "$@" )" ] ; then
    echo "... git commit '$msg' of '$@'"
    dry_run git add "$@"
    dry_run git commit -m "$msg" -m "Generated-by: le-lego-$PROVIDER $0"
    dry_run touch "$flag"
    dry_run touch ".dirty.at_least_one"
  fi
}

git_commit_and_mark_dirty ()
{
  if_true "GIT_COMMITS" _do_git_commit_and_mark_dirty "$@"
}

git_commit_globals ()
{
  ## Commit global stuff
  git_commit "Updated accounts" "./accounts/"
  git_commit "Updated core scripts" "./bin/" "./lib/"
  git_commit "Updated global configuration" "./global_defs.sh"
  git_commit "Updated hook scripts" "./hooks/"
}


###############################
# Logic to update a single cert

update_single_cert () {
  local cert_spec_dir
  cert_spec_dir="$1"

  rm -f ".dirty.single" ## Sanity, just in case...

  cert_name=`basename "$cert_spec_dir"`

  mkdir -p "logs" "logs/$cert_name"
  logfile="logs/$cert_name.log"

  ./lib/update_single.sh "$cert_spec_dir" 2>&1 | tee "$logfile"

  if [ -e ".dirty.single" ] ; then
    echo "... certificate updated"
    mv "$logfile" "logs/$cert_name/last_update.log"
  else
    echo "... certificate was not updated"
    mv "$logfile" "logs/$cert_name/last_run.log"
  fi
  rm -f ".dirty.single"

  git_commit "Updated logs for certificate $cert_name" "logs/$cert_name"
}


#######################################################
# Read the global configuration file and apply defaults

if [ -e "./global_defs.sh" ] ; then
  echo "... reading global_defs.sh"
  . "./global_defs.sh"
fi
. "./lib/defaults.sh"

fatal_if_disabled "all certificates updates disabled via 'global_defs.sh'"

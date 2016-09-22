#
# Our shell utilities library
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

exit_if_disabled ()
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
    git add "$@"
    git commit -m "$msg" -m "Generated-by: le-lego-cloudflare $0"
  fi
}

git_commit ()
{
  if_true "GIT_COMMITS" _do_git_commit "$@"
}

git_commit_globals ()
{
  ## Commit global stuff
  git_commit "Updated accounts" "./accounts/"
  git_commit "Updated core scripts" "./bin/" "./lib/"
  git_commit "Updated global configuration" "./global_defs.sh"
}


###############################
# Logic to update a single cert

update_single_cert () {
  local cert_file
  cert_file="$1"

  cert_name=`basename "$cert_file"`
  mkdir -p "logs"
  logfile="logs/$cert_name.log"
  ./lib/update_single.sh "$cert_file" 2>&1 | tee "$logfile"
  git_commit "Updated last run logs for certificate $cert_name" "$logfile"
}


####################################
# Read the global configuration file

if [ -e "global_defs.sh" ] ; then
  echo "... reading global_defs.sh"
  . "./global_defs.sh"
fi

exit_if_disabled "FATAL: all certificates updates disabled on the global defs.sh"

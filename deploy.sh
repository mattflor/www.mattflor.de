#!/bin/bash

## set defaults ----------------------------------------------------------------
FILES=('public')
USER='root'
SERVER='www.mattflor.de'
DOCROOT='/var/www/html'

## usage / help message --------------------------------------------------------
USAGE="Usage: $0 [OPTIONS] [FILES]
Deploy FILES to a SERVER via secure copy (scp).

OPTIONS:
    -u, --user USER           login as USER on server; default: $USER
    -s, --server SERVER       deploy to url SERVER; default: $SERVER
    -d, --docroot DOCROOT     document root directory on the server is located at DOCROOT;
                              default: $DOCROOT
    -t, --test                test deploy call; setting this flag will only 
                              print the generated call but do nothing

Default FILES: ${FILES[@]}

Thus, calling the script without any options or file arguments results in 
this default call:
scp -r ${FILES[@]} ${USER}@${SERVER}:${DOCROOT}

You will then be asked for the appropriate password.
"


## parse options ---------------------------------------------------------------
# transform long options to short ones as getopts only handles short options
for arg in "$@"; do
  shift
  case "$arg" in
    "--user")       set -- "$@" "-u" ;;
    "--server")     set -- "$@" "-s" ;;
    "--docroot")    set -- "$@" "-d" ;;
    "--test")       set -- "$@" "-t" ;;
    "--help")       set -- "$@" "-h" ;;
    *)              set -- "$@" "$arg"
  esac
done

# use getopts to parse options
while getopts ":u:s:d:th" opt; do
  case $opt in
    u)
      USER="$OPTARG"
      ;;
    s)
      SERVER="$OPTARG"
      ;;
    d)
      DOCROOT="$OPTARG"
      ;;
    t)
      TEST=true
      ;;
    h)
      printf "$USAGE"
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      printf "$USAGE"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      printf "$USAGE"
      exit 1
      ;;
  esac
done
shift $(( $OPTIND - 1 ))

## remaining arguments are the files to deploy ---------------------------------
if [[ $# -gt 0 ]]; then
    unset FILES
    FILES="$@"
fi

## deploy ----------------------------------------------------------------------
DEPLOY_CALL="scp -r ${FILES[@]} ${USER}@${SERVER}:${DOCROOT}"

if [ "$TEST" = true ]; then
    echo
    echo "Test call (without the -t flag, we would do the following):"
    echo "$DEPLOY_CALL"
    exit 1
fi


echo $DEPLOY_CALL
$DEPLOY_CALL

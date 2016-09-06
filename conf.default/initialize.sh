#!/bin/bash
#-------------------------------------------------------------------------------
# SCRIPT.........: initialize
# ACTION.........: Initialize variables for backup scripts
# COPYRIGHT......: Christos Pontikis - http://www.pontikis.gr
# LICENSE........: MIT (see https://opensource.org/licenses/MIT)
# DOCUMENTATION..: See README for instructions
#-------------------------------------------------------------------------------

# PARAMETERS -------------------------------------------------------------------
FIND="$(which find)"
TAR="$(which tar)"
GZIP="$(which gzip)"
DATE="$(which date)"
CHMOD="$(which chmod)"
MKDIR="$(which mkdir)"
RM="$(which rm)"
TEE="$(which tee)"

use_7z=1
# ATTENTION -------------------------------------------------------------------------------------------
#Enclosing characters in double quotes preserves the literal value of all characters within the quotes,
#with the exception of $, `, \, and, when history expansion is enabled, !.
#...so if you escape those (and the quote itself, of course) you're probably okay.
# http://stackoverflow.com/questions/15783701/which-characters-need-to-be-escaped-in-bash-how-do-we-know-it
passwd_7z="YOUR_PASSWORD_HERE"
cmd_7z="$(which 7z) a -p$passwd_7z -mx=9 -mhe -t7z"
filetype_7z=7z
# you should use the following (NOT recommended) -------------------------------
# cmd_7z="$(which 7z) a -p$passwd_7z -mx=9 -mm=Deflate -mem=AES256 -tzip"
# filetype_7z=zip

MYSQLDUMP="$(which mysqldump)"

S3CMD="$(which s3cmd)"
S3CMD_SYNC_PARAMS="--verbose --config /root/.s3cfg --delete-removed --server-side-encryption"
# ATTENTION --------------------------------------------------------------------
# s3cmd versions < 0.9 ---------------------------------------------------------
# add server side encryption using "--add-header=x-amz-server-side-encryption:AES256"
# s3cmd latest version ---------------------------------------------------------
# add server side encryption using"--server-side-encryption"

days_rotation=14
backuproot='/root/backup'

# ------------------------------------------------------------------------------
# make backup directories in case they do not exist
if [ ! -d "$backuproot" ]; then $MKDIR -p $backuproot; fi

# define variables 
logfile="$backuproot/log/backup.log"

# make backup directories in case they do not exist
if [ ! -d "$backuproot/log" ]; then $MKDIR $backuproot/log; fi

# ------------------------------------------------------------------------------
case $1 in
www)
    # define variables 
    dir_www='www'
    all_prefix_www='www'
    wwwroot='/var/www/'

    # make backup directories in case they do not exist
    if [ ! -d "$backuproot/$dir_www" ]; then $MKDIR $backuproot/$dir_www; fi
  ;;
mysql)
    # define variables 
    dir_mysql='mysql'
    all_prefix_mysql='mysql'
    mysql_user='username_here'
    mysql_password='password_here'

    # make backup directories in case they do not exist
    if [ ! -d "$backuproot/$dir_mysql" ]; then $MKDIR $backuproot/$dir_mysql; fi
  ;;
conf)
    # define variables 
    dir_conf='conf'

    # make backup directories in case they do not exist
    if [ ! -d "$backuproot/$dir_conf" ]; then $MKDIR $backuproot/$dir_conf; fi
  ;;
scripts)
    # define variables 
    dir_scripts='scripts'

    # make backup directories in case they do not exist
    if [ ! -d "$backuproot/$dir_scripts" ]; then $MKDIR $backuproot/$dir_scripts; fi
  ;;
docs)
    # define variables
    dir_docs='docs'

    # make backup directories in case they do not exist
    if [ ! -d "$backuproot/$dir_docs" ]; then $MKDIR $backuproot/$dir_docs; fi
  ;;
s3_plain)
    # define variables
    # ATTENTION must end with /
    s3_plain_path='s3://bucket_name/path/to/plain_backup/'
  ;;
esac


# UDF .............................................
function createlog {
      dt=`$DATE "+%Y-%m-%d %H:%M:%S"`
      logline="$dt | $1"
      echo -e $logline; echo -e $logline >> $logfile
}
#!/bin/bash

BASE_DIR=.
DATA_DIR=../Data
TEMP_DIR=$DATA_DIR/temp
PKG_DIR=$DATA_DIR/packages
LANG=C
export LANG

#TODO: ADD OPTARGS TO CONFIGURE VARIABLES
while getopts ":u:p:w:" OPT; do
	case ${OPT} in
		u) SSO_USERNAME="$OPTARG";;
		p) SSO_PASSWORD="$OPTARG";;
		w) URL="$OPTARG";;
	esac
done

mkdir -p $PKG_DIR

# Path to wget command
WGET=/usr/bin/wget

# Location of cookie file
COOKIE_FILE=$TEMP_DIR/$$.cookies

SSO_FILE=$TEMP_DIR/sso.out

# Output directory and file
OUTPUT_DIR=$PKG_DIR/$(echo "$URL" | sed -e 's/^.*patch_file=\([A-Za-z_.0-9]*\).*/\1/')


if [ ! -f $OUTPUT_DIR ]; then 
	SSO_RESPONSE=`$WGET --user-agent="Mozilla/5.0" https://updates.oracle.com/Orion/Services/download 2>&1|grep Location`
	SSO_TOKEN=`echo $SSO_RESPONSE| cut -d '=' -f 2|cut -d ' ' -f 1`
	SSO_SERVER=`echo $SSO_RESPONSE| cut -d ' ' -f 2|cut -d 'p' -f 1,2`
	SSO_AUTH_URL=sso/auth
	AUTH_DATA="ssousername=$SSO_USERNAME&password=$SSO_PASSWORD&site2pstoretoken=$SSO_TOKEN"
	$WGET --user-agent="Mozilla/5.0" --secure-protocol=auto --post-data $AUTH_DATA --save-cookies=$COOKIE_FILE --keep-session-cookies $SSO_SERVER$SSO_AUTH_URL -O $SSO_FILE
	$WGET  --user-agent="Mozilla/5.0"  --load-cookies=$COOKIE_FILE --save-cookies=$COOKIE_FILE --keep-session-cookies $URL -O $OUTPUT_DIR
fi

rm -f download
rm -f $SSO_FILE
rm -f $COOKIE_FILE
rm -rf $TEMP_DIR/*
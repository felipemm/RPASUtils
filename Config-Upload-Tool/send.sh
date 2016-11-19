#!/bin/bash

DATE=`date +%Y-%m-%d_%H.%M.%S`
CONFIG_NAME=RDF

DEV_USER=rdfadmin
DEV_SERVER=222.222.222.222
DEV_FOLDER=/u01/rdf/environments/<client-name>/build

QA_USER=rdfadmin
QA_SERVER=222.222.222.222
QA_FOLDER=/u01/rdf/environments/<client-name>/build

PRD_USER=rdfadmin
PRD_SERVER=222.222.222.222
PRD_FOLDER=/u01/rdf/environments/<client-name>/build

CURRENT_USER=''
CURRENT_SERVER=''
CURRENT_FOLDER=''
SERVER=''


case $1 in
    dev) 
        CURRENT_USER=$DEV_USER
        CURRENT_SERVER=$DEV_SERVER
        CURRENT_FOLDER=$DEV_FOLDER
        SERVER=$DEV_USER@$DEV_SERVER:$DEV_FOLDER
        ;;
    qa) 
        CURRENT_USER=$QA_USER
        CURRENT_SERVER=$QA_SERVER
        CURRENT_FOLDER=$QA_FOLDER
        SERVER=$QA_USER@$QA_SERVER:$QA_FOLDER
        ;;
    prd) 
        CURRENT_USER=$PRD_USER
        CURRENT_SERVER=$PRD_SERVER
        CURRENT_FOLDER=$PRD_FOLDER
        SERVER=$PRD_USER@$PRD_SERVER:$PRD_FOLDER
        ;;
esac

if [[ '$SERVER' == '' ]]; then
    echo "Please define the server you want to run this script (dev|qa|prd)!"
    exit -1
fi

echo "Removing *.xml~ files from config"
find . -name "*.xml~" -exec rm -vf {} \;
touch $CONFIG_NAME
echo "Done removing."

if [[ -f ${CONFIG_NAME}.zip ]]; then 
    echo "Moving current $CONFIG_NAME.zip to $CONFIG_NAME_$DATE.zip backup"
    mv ${CONFIG_NAME}.zip ${CONFIG_NAME}_${DATE}.zip
    echo "Done moving."
fi

echo "Compressing config to $CONFIG_NAME.zip"
zip -r RDF.zip RDF/
echo "Done compression."

#check if you have a RSA key in you machine, otherwise create it
if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -b 2048
fi
cat ~/.ssh/id_rsa.pub | ssh ${CURRENT_USER}@${CURRENT_SERVER} "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"


echo "Executing SCP to the following route: $SERVER"
scp RDF.zip ${SERVER}
echo "Done transfer."

echo "Connecting to the server via SSH"
ssh ${CURRENT_USER}@${CURRENT_SERVER} #-t '. /etc/profile; . ~/.bash_profile; ddminstall build'

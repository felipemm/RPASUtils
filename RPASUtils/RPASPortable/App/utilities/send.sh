#!/bin/bash

#Source Specific Client Environment
. config.sh

DATE=`date +%Y-%m-%d_%H.%M.%S`

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
        CURRENT_USER=$UAT_USER
        CURRENT_SERVER=$UAT_SERVER
        CURRENT_FOLDER=$UAT_FOLDER
        SERVER=$UAT_USER@$UAT_SERVER:$UAT_FOLDER
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

echo CURRENT_USER=$CURRENT_USER
echo CURRENT_SERVER=$CURRENT_SERVER
echo CURRENT_FOLDER=$CURRENT_FOLDER
echo SERVER=$SERVER
echo CONFIG_NAME=$CONFIG_NAME
echo CONFIG_PATH=$CONFIG_PATH
echo CONFIG_SVN_PATH=$CONFIG_SVN_PATH

#Clear xml~ backup files from rpas
echo "Removing *.xml~ files from config"
find ${CONFIG_PATH}/${CONFIG_NAME} -name "*.xml~" -exec rm -vf {} \;
touch ${CONFIG_PATH}/${CONFIG_NAME}
echo "Done removing."



if [ ! -z "$CONFIG_SVN_PATH" ]; then
    #Remove current SVN config folder
    rm -rf ${CONFIG_SVN_PATH}/${CONFIG_NAME}
    if [[ $? != 0 ]]; then
        echo "Error while removing current SVN config folder"
        exit 1
    fi
    #Copy the config to SVN
    echo "Copying the $CONFIG_NAME from Desktop Folder"
    cp -rf "${CONFIG_PATH}/${CONFIG_NAME}" "${CONFIG_SVN_PATH}"
    if [[ $? != 0 ]]; then
        echo "Error while copying to SVN"
        exit 1
    fi
fi


#Backup current configuration zip 
if [[ -f ${CONFIG_PATH}/${CONFIG_NAME}.zip ]]; then 
    echo "Moving current $CONFIG_NAME.zip to $CONFIG_NAME_$DATE.zip backup"
    mv "${CONFIG_PATH}/${CONFIG_NAME}.zip" "${CONFIG_PATH}/${CONFIG_NAME}_${DATE}.zip"
    echo "Done moving."
fi


#Compress the new config
echo "Compressing config to $CONFIG_NAME.zip"
zip -r "${CONFIG_PATH}/${CONFIG_NAME}.zip" "${CONFIG_PATH}/${CONFIG_NAME}"
if [[ $? != 0 ]]; then
    exit 1
fi
echo "Done compression."



#check if you have a RSA key in you machine, otherwise create it
echo "Adding the RSA Key for seamless login to the SERVER"
if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -b 2048
fi
echo 'cat ~/.ssh/id_rsa.pub | ssh ${CURRENT_USER}@${CURRENT_SERVER} "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"'
cat ~/.ssh/id_rsa.pub | ssh ${CURRENT_USER}@${CURRENT_SERVER} "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
echo "DONE!"

echo "Executing SCP to the following route: $SERVER"
scp ${CONFIG_PATH}/${CONFIG_NAME}.zip ${SERVER}
echo "Done transfer."

echo "Connecting to the server via SSH"
ssh ${CURRENT_USER}@${CURRENT_SERVER} #-t '. /etc/profile; . ~/.bash_profile; ddminstall build'

#!/bin/bash

DATE=`date +%Y-%m-%d_%H.%M.%S`


RPAS_USER=rdfadmin
RPAS_SERVER=10.46.0.82
RPAS_FOLDER=/u01/rdf/environments/cea/domains/RDF/fusionClient

WLS_USER=wlsrdf
WLS_SERVER=10.46.0.82
WLS_FOLDER=/u01/rdf/fusionclient/config/MultiSolution


#check if you have a RSA key in you machine, otherwise create it
if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -b 2048
fi
cat ~/.ssh/id_rsa.pub | ssh ${RPAS_USER}@${RPAS_SERVER} "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | ssh ${WLS_USER}@${WLS_SERVER} "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"



echo "Copying New Taskflow to Fusion Client"
command=""
if [[ ${RPAS_SERVER} == ${WLS_SERVER} ]]; then
    command="
        cp ${RPAS_FOLDER}/taskflow.xml ${WLS_FOLDER}/Taskflow_MultiSolution.xml
        cp ${RPAS_FOLDER}/taskflowBundle.properties ${WLS_FOLDER}/resources/MultiSolutionBundle.properties
    "
else
    command="
        if [[ ! -f ~/.ssh/id_rsa.pub ]]; then
            ssh-keygen -t rsa -b 2048
        fi
        cat ~/.ssh/id_rsa.pub | ssh ${RPAS_USER}@${RPAS_SERVER} \"mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys\"
        scp ${RPAS_USER}@${RPAS_SERVER}:${RPAS_FOLDER}/taskflow.xml ${WLS_FOLDER}/Taskflow_MultiSolution.xml
        scp ${RPAS_USER}@${RPAS_SERVER}:${RPAS_FOLDER}/taskflowBundle.properties ${WLS_FOLDER}/resources/MultiSolutionBundle.properties
    "

fi

#echo ssh ${WLS_USER}@${WLS_SERVER} "${command}"
ssh ${WLS_USER}@${WLS_SERVER} "${command}"


echo "DONE!"
sleep 2
#!/bin/ksh

########################### USER SPECIFIC AND BASIC ENV CONFIG ###########################

export PS1="\u@\h:\w$ "
export HOSTNAME=`uname -n`

set -o vi
set +u
alias ls='ls --color=none'

#export TMP=/tmp
export TMP=/u01/rdf/environments/<client-name>/temp
export TEMP=$TMP
export TMPDIR=$TMP
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export PATH=$JAVA_HOME:$PATH

########################### RPASCA ###########################
export RPASCA_RPAS=/datos/rdf
export RPASCA_ENVIRONMENT=$RPASCA_RPAS/environments/<client-name>
export SSCL_SCRIPTS=$RPASCA_ENVIRONMENT/scripts/sscl
export RPASCL_SCRIPTS=$RPASCA_ENVIRONMENT/scripts/rpascl
export WLCL_SCRIPTS=$RPASCA_ENVIRONMENT/scripts/wlcl
export RDFCL_SCRIPTS=$RPASCA_ENVIRONMENT/scripts/rdfcl
export CURVECL_SCRIPTS=$RPASCA_ENVIRONMENT/scripts/curvecl
export PATH=$SSCL_SCRIPTS:$RPASCL_SCRIPTS:$WLCL_SCRIPTS:$RDFCL_SCRIPTS:$CURVECL_SCRIPTS:$PATH


export RPASCL_DM_NAME=RDF
export RPASCL_LISTENING_PORT=55555
export RPASCL_SERVER_IP=$(hostname -i)


# Force environment override
export RPASCL_ENVIRONMENT_SET=0
export SSCL_ENVIRONMENT_SET=0
export WLCL_ENVIRONMENT_SET=0
export RDFCL_ENVIRONMET_SET=0
export CURVECL_ENVIRONMET_SET=0

. sscl_environment.ksh
. rpascl_environment.ksh
. wlcl_environment.ksh
. rdfcl_environment.ksh
. curvecl_environment.ksh


########################### BSA ###########################
export BSA_ARCHIVE_DIR=$TMP
export BSA_CONFIG_DIR=$TMP
export BSA_LOG_HOME=$SSCL_LOGS
export BSA_LOG_LEVEL=INFORMATION
export BSA_LOG_TYPE=1
export BSA_MAX_PARALLEL=4
export BSA_SCREEN_LEVEL=INFORMATION
export BSA_TEMP_DIR=$TMP



########################### ALIASES - STANDARD PATHS ###########################

alias lg='mkdir -p $SSCL_LOGS/$SSCL_TODAY && cd $SSCL_LOGS/$SSCL_TODAY'
alias dm='cd $RPASCL_MASTER_DOMAIN'
alias r='cd $RPASCL_SCRIPTS'
alias s='cd $SSCL_SCRIPTS'
alias w='cd $WLCL_SCRIPTS'
alias rdf='cd $RDFCL_SCRIPTS'
alias c='cd $CURVECL_SCRIPTS'
alias n='cd $RPASCA_ENVIRONMENT'
alias i='cd $RPASCL_DATA_IN'
alias o='cd $RPASCL_DATA_OUT'
alias t='cd $SSCL_TEMP'
alias b='cd $RPASCL_BUILD'
alias bkp='cd $RPASCL_BACKUPS'
alias ff='f=`ls -td */ | head -1`; cd $f; ls -ltr'
alias check='ps -ef | grep `whoami`'
alias spc='du -sh *'

########################### ALIASES - RPAS SHORTCUTS ###########################

alias ddmaddgroup='_j(){ usermgr -d $RPASCL_MASTER_DOMAIN -addGroup $1 -label $1; }; _j'
alias ddmadduser='_j(){ usermgr -d $RPASCL_MASTER_DOMAIN -add $1 -label $1 -group $2 -admin; }; _j'
alias ddmusers='usermgr -d $RPASCL_MASTER_DOMAIN -list'
alias ddmping='DomainDaemon -ipaddr $RPASCL_SERVER_IP -port $RPASCL_LISTENING_PORT -wallet file:$RPASCL_WALLET_DIR ping'
alias ddmcheck='DomainDaemon -ipaddr $RPASCL_SERVER_IP -port $RPASCL_LISTENING_PORT -wallet file:$RPASCL_WALLET_DIR showActiveServers'
alias ddmkill='DomainDaemon -ipaddr $RPASCL_SERVER_IP -port $RPASCL_LISTENING_PORT -wallet file:$RPASCL_WALLET_DIR stopActiveServers'
alias ddm='_mdaemon(){ 
    rpascl_manage_listener.ksh -a $1 &
    sleep 2
    lg
    ff
    tail -f rpascl_manage_listener.ksh.log 
}; _mdaemon'
alias mspec='_mspec(){ printMeasure -d $RPASCL_MASTER_DOMAIN -m $1 -specs; }; _mspec'
alias mprint='_mprint(){ printMeasure -d $RPASCL_MASTER_DOMAIN -m $1 -allPopulatedCells; }; _mprint'
alias mfind='_mfind(){ mace -d $RPASCL_MASTER_DOMAIN -find $1 ; }; _mfind'
alias mexp='_mexp(){ 
    echo nohup exportMeasure -d $RPASCL_MASTER_DOMAIN -out $1.csv.ovr -meas $1 -intx $2 -loglevel all
    nohup exportMeasure -d $RPASCL_MASTER_DOMAIN -out $1.csv.ovr -meas $1 -intx $2 -loglevel all &
    sleep 2
    tail -f nohup.out
}; _mexp'
alias ddminstall='_ddminstall(){
    t=$1
    if [ -z "$1" ]; then
        t=patch
    fi
    b
    nohup rpascl_domain_manager.ksh -a $t &
    sleep 3
    lg
    ff
    ff
    while [ ! -e RDF* ]; do
        sleep 1
    done
    tail -f RDF*
}; _ddminstall'
alias runbatch='_rb(){ 
    rpascl_batch.ksh -c $RDFCL_SCRIPTS/rdfcl_run_$1_batch.control &
    sleep 2
    lg
    ff
    tail -f rpascl_batch.ksh.log 
}; _rb'


########################### PROFILE OUTPUT PRINT ###########################
if [[ -d $RPASCL_MASTER_DOMAIN ]]; then
    domaininfo -d $RPASCL_MASTER_DOMAIN -all
else
    echo Domain $RPASCL_MASTER_DOMAIN does not exists. Use \'ddminstall build\' to create it
fi
echo "=============================================="
echo RPASCA_ENVIRONMENT=$RPASCA_ENVIRONMENT
echo RPASCL_MASTER_DOMAIN=$RPASCL_MASTER_DOMAIN
echo RPASCL_LISTENING_PORT=$RPASCL_LISTENING_PORT
echo RPASCL_SERVER_IP=$RPASCL_SERVER_IP
echo "Profile Loaded"

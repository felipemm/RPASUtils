#!/bin/bash

cyan='\e[1;37;44m'
red='\e[1;31m'
endColor='\e[0m'
datetime=$(date +%Y%m%d%H%M%S)

lowercase(){
	echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

####################################################################
# Get System Info
####################################################################
shootProfile(){
	OS=`lowercase \`uname\``
	KERNEL=`uname -r`
	MACH=`uname -m`

	if [[ "${OS}" == "cygwin"* ]]; then
		OS=windows
	elif [[ "${OS}" == "darwin*" ]]; then
		OS=mac
	else
		OS=`uname`
		if [[ "${OS}" = "SunOS" ]] ; then
			OS=Solaris
			ARCH=`uname -p`
			OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
		elif [[ "${OS}" = "AIX" ]] ; then
			OSSTR="${OS} `oslevel` (`oslevel -r`)"
		elif [[ "${OS}" = "Linux" ]] ; then
			if [[ -f /etc/redhat-release ]] ; then
				DistroBasedOn='RedHat'
				DIST=`cat /etc/redhat-release |sed s/\ release.*//`
				PSEUDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
			elif [[ -f /etc/SuSE-release ]] ; then
				DistroBasedOn='SuSe'
				PSEUDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
				REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
			elif [[ -f /etc/mandrake-release ]] ; then
				DistroBasedOn='Mandrake'
				PSEUDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
				REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
			elif [[ -f /etc/debian_version ]] ; then
				DistroBasedOn='Debian'
				if [[ -f /etc/lsb-release ]] ; then
			        	DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
			                PSEUDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
			                REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
            			fi
			fi
			if [[ -f /etc/UnitedLinux-release ]] ; then
				DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
			fi
			OS=`lowercase $OS`
			DistroBasedOn=`lowercase $DistroBasedOn`
		 	readonly OS
		 	readonly DIST
			readonly DistroBasedOn
		 	readonly PSEUDONAME
		 	readonly REV
		 	readonly KERNEL
		 	readonly MACH
		fi

	fi
    
    export SSCL_SYS_OS=$OS
    export SSCL_SYS_DIST=$DIST
    export SSCL_SYS_PSEUDONAME=$PSEUDONAME
    export SSCL_SYS_REV=$REV
    export SSCL_SYS_DistroBasedOn=$DistroBasedOn
    export SSCL_SYS_KERNEL=$KERNEL
    export SSCL_SYS_MACH=$MACH
}
shootProfile

echo "OS: $SSCL_SYS_OS"
echo "DIST: $SSCL_SYS_DIST"
echo "PSEUDONAME: $SSCL_SYS_PSEUDONAME"
echo "REV: $SSCL_SYS_REV"
echo "DistroBasedOn: $SSCL_SYS_DistroBasedOn"
echo "KERNEL: $SSCL_SYS_KERNEL"
echo "MACH: $SSCL_SYS_MACH"
echo "========"
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION


where /q bash
IF ERRORLEVEL 1 (
    ECHO =====================================================================
    ECHO The bash is missing. Ensure it is installed and placed in your PATH.
    ECHO =====================================================================
    pause
    goto MENU
)

:MENU

	CLS
	set M=
	ECHO ...............................................
	ECHO             LOGIC RPAS UTILITIES
	ECHO       Developed by Felipe Matos Moreira
	ECHO                    v1.0
	ECHO ...............................................
	ECHO.
	ECHO SELECT THE OPTION YOU WANT
	ECHO    1 - Set Client PATHs
	ECHO    2 - Send config to DEV Server
	ECHO    3 - Send config to UAT Server
	ECHO    4 - Send config to PRD Server
	ECHO    5 - Copy Taskflow to Weblogic
	ECHO    6 - EXIT
	ECHO.

	SET /P M=Type option 1-6 then press ENTER:
	IF [%M%] == [] (
		ECHO Nothing Selected! To EXIT, press 6
		GOTO MENU
	)
	IF %M%==1 GOTO OPTION1
	IF %M%==2 GOTO OPTION2
	IF %M%==3 GOTO OPTION3
	IF %M%==4 GOTO OPTION4
	IF %M%==5 GOTO OPTION5
	IF %M%==6 GOTO EOF





:OPTION1
	CLS
	ECHO CREATE OR USE PREVIOUS CLIENT SETTINGS
	ECHO.
	ECHO CURRENT CONFIGURED CLIENTS:
	set count=2
	set input=0
    echo  1 - Add New Client
	for %%x in (clients\config_*.sh) do (
		echo  !count! - %%~nx%%~xx
		set mis!count!=%%~nx%%~xx
		set /A count=!count!+1
	)
	set /A count=%count%-1
	ECHO.
	set /P input=Please select or ENTER to continue [1-%count%]:
    
	if %input% == 0 GOTO MENU
	if %input% GTR %count% GOTO MENU

    if %input% == 1 (GOTO ADD_NEW_CLIENT) ELSE (GOTO USE_CLIENT)
    
    :USE_CLIENT
        set runmis=mis%input%
		call set run_mis=%%%runmis%%%
		set name=%run_mis%
		echo Selected %name% to use.
        echo . clients/%name% > config.sh
        %cd%/../dos2unix -D utf8 config.sh
        GOTO EOF_OPTION1
    
    
    :ADD_NEW_CLIENT
        set /P client_name=Inform the CLIENT: 
        IF [%client_name%] == [] GOTO MENU
        SET /P config_name=Inform the CONFIG_NAME: 
        SET /P config_path=Inform the CONFIG_PATH: 
        SET /P config_svn_path=Inform the CONFIG_SVN_PATH: 
        set /P INPUT=Configure DEV?(Y/N)
        If /I "%INPUT%"=="y" (
            SET /P dev_user=Inform the DEV_USER:
            SET /P dev_server=Inform the DEV_SERVER: 
            SET /P dev_folder=Inform the DEV_FOLDER: 
        )
        set /P INPUT=Configure UAT?(Y/N)
        If /I "%INPUT%"=="y" (
            SET /P uat_user=Inform the UAT_USER:
            SET /P uat_server=Inform the UAT_SERVER: 
            SET /P uat_folder=Inform the UAT_FOLDER: 
        )
        set /P INPUT=Configure PRD?(Y/N)
        If /I "%INPUT%"=="y" (
            SET /P prd_user=Inform the PRD_USER:
            SET /P prd_server=Inform the PRD_SERVER: 
            SET /P prd_folder=Inform the PRD_FOLDER: 
        )
        (
            ECHO #!/bin/bash
            ECHO.
            ECHO CONFIG_NAME=%config_name%
            ECHO CONFIG_PATH=%config_path%
            ECHO CONFIG_SVN_PATH='%config_svn_path%'
            ECHO. 
            ECHO DEV_USER=%dev_user%
            ECHO DEV_SERVER=%dev_server%
            ECHO DEV_FOLDER=%dev_folder%
            ECHO. 
            ECHO QA_USER=%qa_user%
            ECHO QA_SERVER=%qa_server%
            ECHO QA_FOLDER=%qa_folder%
            ECHO. 
            ECHO PRD_USER=%prd_user%
            ECHO PRD_SERVER=%prd_server%
            ECHO PRD_FOLDER=%prd_folder%
        ) > clients/config_%client_name%.sh
        %cd%/../dos2unix -D utf8 clients/config_%client_name%.sh
        
        SET client_name=
        SET config_name=
        SET config_path=
        SET config_svn_path=
        SET dev_user=
        SET dev_server=
        SET dev_folder=
        SET uat_user=
        SET uat_server=
        SET uat_folder=
        SET prd_user=
        SET prd_server=
        SET prd_folder=
        GOTO OPTION1
        
    :EOF_OPTION1
        ECHO Done!
        pause
        GOTO MENU 


:OPTION2
    bash -c "./send.sh dev"
    ECHO Done!
    pause
    GOTO MENU 

    
:OPTION3
    bash -c "./send.sh uat"
    ECHO Done!
    pause
    GOTO MENU 

    
:OPTION4
    bash -c "./send.sh prd"
    ECHO Done!
    pause
    GOTO MENU 
    
    
:OPTION5
    bash -c "./taskflow.sh"
    ECHO Done!
    pause
    GOTO MENU 

:EOF
    
ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
::mode con: cols=120 lines=30

::SET APP_HOME=%CD%\..\App
::SET APP_DATA_HOME=%CD%\..\Data

::Prefer Cygwin over Windows BASH
SET USING_BASH="WINDOWS BASH"
IF NOT EXIST C:\cygwin GOTO NOCYGWIN
SET PATH=C:\cygwin\bin;%PATH%
SET USING_BASH="CYGWIN"
:NOCYGWIN

IF [%APP_HOME%] == [] (SET APP_HOME=%CD%)
    


SET ARPO_HOME=%APP_HOME%\ARPOPlatform
SET TEMP_HOME=%APP_DATA_HOME%\temp
SET PKG_HOME=%APP_DATA_HOME%\packages
SET CREDENTIAL_FILE=%APP_DATA_HOME%\credentials.cfg
SET PKG_URL_FILE=%APP_DATA_HOME%\packages.cfg
SET BASHRC_FILE=%APP_HOME%\.bashrc
SET VARS_FILE=%APP_DATA_HOME%\envVars.bat


mkdir %APP_HOME% %APP_DATA_HOME% %ARPO_HOME% %TEMP_HOME% %PKG_HOME%



:MENU
    
    CD %APP_HOME%
	CLS
	set M=
	ECHO ...............................................
	ECHO      LOGIC RPAS ENVIRONMENT CONFIGURATOR
	ECHO       Developed by Felipe Matos Moreira
	ECHO                    v2.0
	ECHO ...............................................
	ECHO.
    ECHO BASH (%USING_BASH%)
    ::where bash
	ECHO.
	ECHO SELECT THE OPTION YOU WANT
	ECHO    1 - Set My Oracle Support Credentials
	ECHO    2 - Add URL to a new RPAS Package Version
	ECHO    3 - Download an RPAS Package from Oracle
	ECHO    4 - Configure a Package
	ECHO    5 - Set Environment Variables
	ECHO    6 - Print Environment Variables
	ECHO    7 - Install CYGWIN
	ECHO    8 - RPAS Utilities
	ECHO    9 - EXIT
	ECHO.

	SET /P M=Type option 1-9 then press ENTER:
	IF [%M%] == [] (
		ECHO Nothing Selected! To EXIT, press 9
		GOTO MENU
	)
	IF %M%==1 GOTO OPT1
	IF %M%==2 GOTO OPT2
	IF %M%==3 GOTO OPTION3
	IF %M%==4 GOTO OPTION4
	IF %M%==5 GOTO OPTION5
	IF %M%==6 GOTO OPTION6
	IF %M%==7 GOTO OPTION7
	IF %M%==8 GOTO OPTION8
	IF %M%==9 GOTO EOF

::===============================================
::    CONFIGURE MY ORACLE SUPPORT CREDENTIALS
::===============================================
:OPT1

	CLS
	ECHO Inform your e-mail and password used to connect to MOS
	ECHO.
	set /P mos_user=User (e-Mail):
	set /P mos_pwd=Password:
	::ECHO export SSO_USERNAME=%mos_user% > %CREDENTIAL_FILE%
	::ECHO export SSO_PASSWORD=%mos_pwd% >> %CREDENTIAL_FILE%
	echo %mos_user% %mos_pwd% > %CREDENTIAL_FILE%
	ECHO.
	ECHO Credentials set!
	set mos_user=
	set mos_pwd=
	pause
	goto MENU 


::===============================================
::   ADD RPAS PACKAGES URL TO DOWNLOAD FROM MOS
::===============================================
:OPT2

	CLS
	ECHO Inform the version and the corresponding URL to download
	ECHO.
	ECHO Current available versions for download
	for /f "tokens=1,2 delims= " %%A in (%PKG_URL_FILE%) do echo    %%A
	ECHO.
	SET /P version=Inform the Version (x.x.x.x): 
	IF [%version%] == [] GOTO MENU
	SET /P url=Inform the URL (inside double quotes): 
	ECHO %url%
	ECHO %version% %url%  >> %PKG_URL_FILE%
	ECHO.
	ECHO Package URL set!
	PAUSE
	SET version=
	SET url=
	GOTO MENU 


::===============================================
::    DOWNLOAD A PACKAGE FROM MOS
::===============================================
:OPTION3
	
	CLS

	if not exist %CREDENTIAL_FILE% (
		echo %CREDENTIAL_FILE% does not exists. Create it using option 1.
		pause
		goto MENU
	)
	if not exist %PKG_URL_FILE% (
		echo %PKG_URL_FILE% does not exists. Add an URL first using option 2.
		pause
		goto MENU
	)
	where /q bash
	IF ERRORLEVEL 1 (
		ECHO The bash is missing. Ensure it is installed and placed in your PATH.
		pause
		goto MENU
	)

	ECHO Inform the version you want to download
	ECHO.
	ECHO Current available versions for download
	::for /f "tokens=1,2 delims= " %%A in (%PKG_URL_FILE%) do echo    %%A
	::ECHO.
	::SET /P version=Which version do you want to install (x.x.x.x format):
	::IF [%version%] == [] GOTO MENU

	set count=1
	set input=0
	for /f "tokens=1,2 delims= " %%A in (%PKG_URL_FILE%) do (
		echo  !count! - %%A
		set mis!count!=%%A
		set /A count=!count!+1
	)
	set /A count=%count%-1
	ECHO.
	set /P input=Please select or ENTER to continue [1-%count%]:
	if %input% == 0 GOTO MENU
	if %input% LEQ %count% GOTO RUN_OPTION3
	GOTO MENU

	:RUN_OPTION3
		set runmis=mis%input%
		call set run_mis=%%%runmis%%%
		set version=%run_mis%
		echo Selected %version% to download.
		
		for /f "tokens=1,2 delims= " %%A in (%CREDENTIAL_FILE%) do (
			SET USER=%%A
			SET PSWD=%%B
		)
		
		for /f "tokens=1,2 delims= " %%A in (%PKG_URL_FILE%) do (
			if [%%A] == [%version%] (
				ECHO export USERNAME=%USER% > %BASHRC_FILE%
				ECHO export PASSWORD=%PSWD% >> %BASHRC_FILE%
				ECHO export URL=%%B >> %BASHRC_FILE%
				ECHO ./downloadRPAS.sh -u $USERNAME -p $PASSWORD -w $URL >> %BASHRC_FILE%
				ECHO exit >> %BASHRC_FILE%
				dos2unix %BASHRC_FILE%
				call bash --rcfile ./.bashrc
				GOTO EOF_OPTION3
			)
		)
		
		ECHO.
		ECHO Package URL not found! Use option 2 to add the URL for download first
		PAUSE
		GOTO MENU 
	
	:EOF_OPTION3
		ECHO.
		ECHO Package URL set!
		PAUSE
		SET version=
		SET USER=
		SET PSWD=
		GOTO MENU 


::===============================================
::    CONFIGURE A RPAS VERSION TO USE
::===============================================
:OPTION4

	CLS
	ECHO This will configure a new RPAS version to your rig.
	ECHO.
    if NOT EXIST %PKG_HOME%\*.* ( 
        ECHO No Packages found in %PKG_HOME%. You need to download at least one from MOS to install it.
        PAUSE
        GOTO OPTION3
    )
    if EXIST %ARPO_HOME%\1* ( 
        ECHO Current versions installed:
        for /D %%t in (%ARPO_HOME%\1*) do ECHO     %%~nt
    ) else (
        ECHO No RPAS version was installed.
    )
    ECHO.
	ECHO Do you want to install any of these available packages?
	set count=1
	set input=0
	for %%x in (%PKG_HOME%\*.*) do (
		echo  !count! - %%~nx%%~xx
		set mis!count!=%%~nx%%~xx
		set /A count=!count!+1
	)
	set /A count=%count%-1
	ECHO.
	set /P input=Please select or ENTER to continue [1-%count%]:
	if %input% == 0 GOTO EOF_OPTION4
	if %input% LEQ %count% GOTO RUN_OPTION4
	GOTO EOF_OPTION4
	
	:RUN_OPTION4
		set runmis=mis%input%
		call set run_mis=%%%runmis%%%
		set package=%run_mis%
		echo Package %run_mis% found in %PKG_HOME%.
		
		mkdir %TEMP_HOME%\%package%
		echo Processing file %package%
		unzip -o %PKG_HOME%\%package% -d %TEMP_HOME%\%package%
		
		for %%z in (%TEMP_HOME%\%package%\*.nt.zip) do (
			echo Processing file %%z
			unzip -o %%z -d %TEMP_HOME%\%package%
		)

		echo Moving ARPOplatform folder to installation folder
		ROBOCOPY %TEMP_HOME%\%package%\ARPOplatform %ARPO_HOME% /E /IS /MOVE
		::move /Y %TEMP_HOME%\%package%\ARPOplatform %APP_HOME%

		echo Removing temporary files
		rd %TEMP_HOME%\%package% /s /q
		goto EOF_OPTION4
	
	
	:EOF_OPTION4
		ECHO.
		ECHO Package %package% ready to be used!
		PAUSE
		set count=
		set input=
		set runmis=
		set run_mis=
		set package=
		GOTO MENU 

        
::===============================================
::    DEFINE THE ENVIRONMENT VARIABLES
::===============================================
:OPTION5
	
	CLS
	ECHO Select the version from the available options
	set count=1
	set input=0
	for /f %%x in ('dir /b %ARPO_HOME%') do (
		echo  !count! - %%x
		set mis!count!=%%x
		set /A count=!count!+1
	)
	set /A count=%count%-1
	ECHO.
	set /P input=Please select or 0 (zero) to exit [1-%count%]:
	if %input% == 0 GOTO MENU
	if %input% LEQ %count% goto run
	goto MENU
	:run
		set runmis=mis%input%
		call set run_mis=%%%runmis%%%
		
		ECHO SET RPAS_HOME=%%APP_HOME%%\ARPOPlatform\%run_mis%\nt\rpas> %VARS_FILE%
		ECHO SET RIDE_HOME=%%APP_HOME%%\ARPOPlatform\%run_mis%\nt\tools>> %VARS_FILE%
		
		ECHO SET RPAS_HOME=%%APP_HOME%%\ARPOPlatform\%run_mis%\nt\rpas
		ECHO SET RIDE_HOME=%%APP_HOME%%\ARPOPlatform\%run_mis%\nt\tools
	
	:EOF_OPTION5
		set count=
		set input=
		set runmis=
		set run_mis=
		pause
		goto MENU


::===============================================
::    PRINT THE ENVIRONMENT VARIABLES
::===============================================
:OPTION6
	echo SET APP_HOME=%APP_HOME%
	echo.
	echo SET APP_DATA_HOME=%APP_DATA_HOME%
	echo.
	echo SET JAVA_HOME=%JAVA_HOME%
	echo.
	echo SET PATH=%PATH%
	echo.
	echo Checking if bash is found in the system
	where bash
	echo.
	echo Checking if RIDE_HOME and RPAS_HOME are set
	echo.
	if exist %VARS_FILE% (
		for /f "tokens=*" %%x in (%VARS_FILE%) do echo %%x
	) else (
		echo %VARS_FILE% does not exists
	)
	echo.
	echo DONE!
	echo.
	pause
	goto MENU
	

::===============================================
::    DEPLOY CYGWIN
::===============================================
:OPTION7
	
	CLS
	set /P INPUT=This will install cygwin under C:/cygwin folder. Are you sure?(Y/N)
	If /I "%INPUT%"=="y" call dpl3cygwin.bat
	goto MENU
    
    
::===============================================
::    RPAS UTILITIES
::===============================================
:OPTION8
	
	CLS
    CD %APP_HOME%/utilities
	call main.bat
	goto MENU
    
    
:EOF
	exit

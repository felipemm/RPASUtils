@ECHO OFF
ECHO Cygwin installation automated

:: Go to this script directory:
CD %~dp0

SETLOCAL

SET CYGSETUP=%CD%\setup-x86_64.exe
SET SITE=http://mirrors.kernel.org/sourceware/cygwin/
SET LOCALDIR=%LOCALAPPDATA%/cygwin
SET ROOTDIR=C:/cygwin

:: =============================================================
REM Prep and verifications:

:: Check cygwin installer:
if exist %CYGSETUP% goto OKSETUP

powershell -Command "Import-Module BitsTransfer; Start-BitsTransfer http://cygwin.com/setup-x86_64.exe %CD%\setup-x86_64.exe"

if exist %CYGSETUP% goto OKSETUP
echo "Aborted as there is no setup-x86_64.exe neither could it be downloaded."
timeout -1
exit

:OKSETUP

:: =============================================================
REM Cygwin categories & packages

SET CYGCATS=archive,base,utils

:: Cygwin core, C/make, editors, libs, shell, vm
:: zlib* includes zlib0 and zlib-devel
SET CYGPKGS=mintty,chere,cygwin-doc,ctags,diffutils
SET CYGPKGS=%CYGPKGS%,gcc-core,make,automake,autoconf,colorgcc
SET CYGPKGS=%CYGPKGS%,gvim,vim,vim-common,mc,nano,hexedit,shed
SET CYGPKGS=%CYGPKGS%,*ncurses*,*readline*,boost,gettext,libattr1,libgcc1,libgmp*,libiconv,libintl8,liblzma5,libpcre*,libstdc++*,libtool,libyaml*,popt,zlib*
SET CYGPKGS=%CYGPKGS%,bash,bashdb,bash-completion,checkbashisms,mksh,xterm,zsh
SET CYGPKGS=%CYGPKGS%,lua,m4,perl,python,ruby
SET CYGPKGS=%CYGPKGS%,p7zip,unzip

:: Data
SET CYGPKGS=%CYGPKGS%,sqlite3,sqliteman

:: Devel basic stuff such as c++, python, vcs..
SET CYGPKGS=%CYGPKGS%,patch,patchutils,quilt,source-highlight
SET CYGPKGS=%CYGPKGS%,cccc,ccdoc,check,clang,clang-analyzer,cppunit,splint,swig
SET CYGPKGS=%CYGPKGS%,python-doc,python-crypto,python-gamin,python-jinja2,python-libxml2,python-mako,python-numpy
SET CYGPKGS=%CYGPKGS%,cvs,git,git-completion,git-gui,mercurial,subversion,svn-load

:: Devel gcc cross compilation deps (texinfo is in Etc section):
SET CYGPKGS=%CYGPKGS%,bison,flex,gmp,mpclib,mpfr
SET CYGPKGS=%CYGPKGS%,libgmp-devel,libmpc-devel,libmpfr-devel,libcloog-isl-devel,libisl-devel

:: Games
SET CYGPKGS=%CYGPKGS%,ctris,ninvaders,sudoku

:: Etc
:: catdoc views msoffice documents; flip manipulates eol; groff gnu formatter
SET CYGPKGS=%CYGPKGS%,catdoc,flip,gtypist,less,odt2txt,pcre,texinfo,xmlto
:: SET CYGPKGS=%CYGPKGS%,abiword,geany,gedit
SET CYGPKGS=%CYGPKGS%,bc,gmp,mathomatic,units
SET CYGPKGS=%CYGPKGS%,GraphicsMagick,aalib,ImageMagick

:: Net
:: aria2 - downloader
:: corkscrew - http proxy
:: gq - graphical ldap browser
:: ttcp - benchmarking
:: zsync - client-side implementation of the rsync algorithm
SET CYGPKGS=%CYGPKGS%,aria2,ca-certificates,corkscrew,curl,dog,gq,mutt,ping,rsh,rsync,rtorrent,tirc,ttcp,whois,zsync
SET CYGPKGS=%CYGPKGS%,lftp,tftp,tftp-server
SET CYGPKGS=%CYGPKGS%,nrss,planet,snownews

:: Net - cygwin section: web
SET CYGPKGS=%CYGPKGS%,httping,lighttpd,links,lynx,mosh,webcheck,wget,wput

:: Sec
SET CYGPKGS=%CYGPKGS%,bcrypt,openssh,outguess,pwgen,steghide

:: System
SET CYGPKGS=%CYGPKGS%,cron,procps,psmisc

:: =============================================================
REM Do it!

ECHO INSTALLING PACKAGES..
%CYGSETUP% -q -v -a x86_64 -d -g -o -Y -O -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -P %CYGPKGS% -C %CYGCATS%

REM -- Cygwin options:
REM -h --help                         print help
REM -q --quiet-mode                   Unattended setup mode
REM -v --verbose                      Verbose output
REM -a --arch                         architecture to install (x86_64 or x86)
REM -d --no-desktop                   Disable creation of desktop shortcut
REM -g --upgrade-also                 also upgrade installed packages
REM -o --delete-orphans               remove orphaned packages
REM -Y --prune-install                prune the installation to only the requested packages
REM -D --download                     Download from internet (DOWNLOAD WITHOUT INSTALLING)
REM -O --only-site                    Ignore all sites except for -s
REM -s --site                         Download site
REM -R --root                         Root installation directory
REM -P --packages                     Specify packages to install
REM -C --categories                   Specify entire categories to install
REM -l --local-package-dir            Local package directory
REM -L --local-install                Install from local directory
REM -x --remove-packages              Specify packages to uninstall
REM -c --remove-categories            Specify categories to uninstall
REM -p --proxy                        HTTP/FTP proxy (host:port)
REM -r --no-replaceonreboot           Disable replacing in-use files on next reboot.
REM -I --include-source               Automatically include source download
REM -n --no-shortcuts                 Disable creation of desktop and start menu shortcuts
REM -N --no-startmenu                 Disable creation of start menu shortcut
REM -K --pubkey                       URL of extra public key file (gpg format)
REM -S --sexpr-pubkey                 Extra public key in s-expr format
REM -u --untrusted-keys               Use untrusted keys from last-extrakeys
REM -U --keep-untrusted-keys          Use untrusted keys and retain all
REM -m --mirror-mode                  Skip availability check when installing from local directory (requires local directory to be clean mirror!)
REM -A --disable-buggy-antivirus      Disable known or suspected buggy anti virus software packages during execution.

:: =============================================================
REM Show installed packages:

ECHO.
ECHO.
ECHO Cygwin installation updated
ECHO.
ECHO Categories:
ECHO %CYGCATS%
ECHO.
ECHO Packages:
ECHO %CYGPKGS%
ECHO.

:: =============================================================

ENDLOCAL

PAUSE
EXIT /B 0

#!/bin/bash
#Outside Requirements: Existing Obelisk Server
#Instructions are for Ubuntu 13.04 and newer

#set user directory as default install dir
INSTALLDIR=$HOME

#set data dir
DATADIR="/var/lib"

#set -e
echo
echo " Mastercoin Tools Installation Script "
echo
if [ "$#" = "1" ] && [ "$1" = "-auto" ] ; then
    PREFIG=n
elif [ "$#" = "2" ]; then
    if [[ "$1" = "-os" ]]; then
        #Absolute path
        SERVER=$2
        PREFIG=CLE
    elif [[ "$1" = "-auto" ]]; then
        #Absolute path
        SERVER=$2
        PREFIG=AUTO
    elif [[ "$1" = "-autoskipprereq" ]]; then
        #Absolute path
        SERVER=$2
        PREFIG=AUTO
        SKIPPREREQ=1
    else
    	HELP=1
    fi
fi


if [ "$1" = "--help" ] || [ $HELP ]; then
     echo " [+] Install script help:"
     echo " --> To run this script type:"
     echo " <sudo bash install-msc.sh>"
     echo " --> To run this script and configure with a specific obelisk server:"
     echo " <bash install-msc.sh -os server-details:port>"
     echo " --> To run this script non-interactively:"
     echo " <bash install-msc.sh -auto>"
     echo " --> To run this script non-interactively, configuring with a specific obelisk server:"
     echo " <bash install-msc.sh -auto server-details:port>"
     echo " This script will install SX and the required prerequisites"
     echo " The SX install script will install libbitcoin, libwallet, obelisk and sx tools."
     echo " The standard path for the installation is /usr/local/"
     echo " The stardard path for the conf files is /etc."
     echo
     exit
fi

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ `id -u` = "0" ]; then
    echo "Running as root"
elif [ -n "$SKIPPREREQ" ]; then
    echo "Skipping prequisites, not running as root"
else
    echo
    echo "[+] ERROR: This script must be run as root." 1>&2
    echo
    echo "<sudo bash install-msc.sh>"
    echo
    exit
fi


while [ -z "$PREFIG" ]; do
	echo "Do you have an obelisk server and wish to enter its details now? [y/n]"
	echo "Need an obelisk server? Try https://wiki.unsystem.net/index.php/Libbitcoin/Servers"
	read PREFIG
done

case $PREFIG in
	y* | Y* )
		ACTIVE=1
		CONFIRM=no
	;;

	CLE)
		ACTIVE=1
		CONFIRM=P
	;;

	AUTO)
		ACTIVE=0
	;;

	*)
		ACTIVE=0
	;;
esac

while [ $ACTIVE -ne 0 ]; do
	case $CONFIRM in

	y* | Y* )
		echo "Writing Details to ~/.sx.cfg"
		echo "You can update/change this file as needed later"
		ACTIVE=0
	;;

	n* | N* )
		SERVER=
		while [ -z "$SERVER" ]; do
			echo "Enter Obelisk server connection details ex: tcp://162.243.29.201:9091"
			echo "If you don't have one yet enter anything, you can update/change this later"
			read SERVER
		done
		CONFIRM=P
	;;

	P)
		echo "You entered: "$SERVER
		echo "Is this correct? [y/n]"
		read CONFIRM
	;;

	*)
		CONFIRM=no
	;;
	esac
done

if [ -n "$SERVER" ]; then
    echo "service = \""$SERVER"\"" > ~/.sx.cfg
else
    echo "#~/.sx.cfg Sample file." > ~/.sx.cfg
    echo "#service = \"tcp://162.243.29.201:9091\"" >> ~/.sx.cfg
fi


if [ -z "$SKIPPREREQ" ]; then
    bash install-prerequisites.sh

    #check for sx and install it if it doesn't exist
    #SX_INSTALLED=`which sx || echo $?`
    which sx
    SX_INSTALLED=$?

    if [[ $SX_INSTALLED -eq 1 ]]; then
            cd $SRC/res
            bash install-sx.sh
    else
            echo "##########################################"
            echo "sx already installed Skipping installation"
            echo "##########################################"

    fi

fi

cd $INSTALLDIR
#git clone https://github.com/grazcoin/mastercoin-tools.git
#git clone https://github.com/curtislacy/mastercoin-tools.git
git clone https://github.com/mastercoin-MSC/mastercoin-tools.git

cp $SRC/res/app.sh $INSTALLDIR/mastercoin-tools
#cp $SRC/scripts/* $INSTALLDIR/mastercoin-tools

#update ~/.sx.cfg with an obelisk server details
# ~/.sx.cfg Sample file.
#service = "tcp://162.243.29.201:9091"

#create the mastercoin tools data directory
mkdir -p $DATADIR/mastercoin-tools
cd $SRC

#temp remove bootstrap until we iron out consensus issue
#wget https://masterchain.info/downloads/ -O list
#latest=`cat list | grep tar.gz | sed -e "s/^.*\"\(.*\)\".*$/\1/" | sort -n -r | head -1`
#wget https://masterchain.info/downloads/$latest -O latest.tar.gz
#rm list
#tar xzf latest.tar.gz -C $DATADIR/mastercoin-tools
#cp -r $DATADIR/mastercoin-tools/www/* $DATADIR/mastercoin-tools/
#rm $DATADIR/mastercoin-tools/revision.json

#add chown for the mastercoin-tools directory.
NAME=`logname`
sudo chown -R $NAME:$NAME $INSTALLDIR/mastercoin-tools
sudo chown -R $NAME:$NAME $DATADIR/mastercoin-tools


echo ""
echo ""
echo "Installation complete"
echo "MSC-Tools should have been downloaded/installed in "$INSTALLDIR/mastercoin-tools
echo "A wrapper app has also been included which automates the following tasks"
echo ""
echo "------Manual Run Commands---------"
echo "To update with the latest transactions run: python msc_parse.py"
echo "To validate and update address balances run: python msc_validate.py"
echo "Once that's done copy the results to the www directory:"
echo "cd "$DATADIR/mastercoin-tools
echo "cp --no-clobber tx/* www/tx/"
echo "cp --no-clobber addr/* www/addr/"
echo "cp --no-clobber general/* www/general/"
echo "----------------------------------"
echo ""
echo "-----Automated Run Commands-------"
echo "start a new screen session or open a detached one with: screen -R msc-tools"
echo "navigate to the install dir: cd "$INSTALLDIR/mastercoin-tools
echo "launch the wrapper: ./app.sh"
echo "you can disconnect from the screen session with <ctrl-a> d"
echo "----------------------------------"

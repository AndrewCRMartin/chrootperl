dir=${HOME}/public_html/chrootperl

. ../../chrootperl.cfg

if [ "X$1" != "X" ]
then
   export SANDBOX=$1
fi

if [ ! -d $SANDBOX/tmp ]
then
   echo "You must install the sandbox first"
   exit 1
fi

if [ ! -d $dir ]
then
   mkdir -p $dir
fi

if [ ! -d $dir ]
then
   echo "Could not create install directory $dir"
   exit 1
fi

cp -v *.cgi *.html .htaccess $dir

cp test2.dat $SANDBOX/tmp

echo " "
echo " "
me=`whoami`
echo "You may now access  the demo code at http://localhost/~${me}/chrootperl/"
echo " "
echo " "


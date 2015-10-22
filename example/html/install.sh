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

if [ "X$DEST" == "X" ]
then
   echo "You must define the DEST environment variable to indicate where chrootperl lives"
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

# Patch in the path to chrootperl
perl -e "while(<>) {s/%%DEST%%/\$ENV{'DEST'}/g; print;}"  perl.cgi >$dir/perl.cgi

cp test2.dat $SANDBOX/tmp

echo " "
echo " "
me=`whoami`
echo "You may now access  the demo code at http://localhost/~${me}/chrootperl/"
echo " "
echo " "


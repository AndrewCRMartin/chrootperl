DEFDIR=${HOME}/public_html/chrootperltutorial
if [ "X$DIR" == "X" ]
then
   DIR=$DEFDIR
fi

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

if [ ! -d $DIR ]
then
   mkdir -p $DIR
fi

if [ ! -d $DIR ]
then
   echo "Could not create install directory $DIR"
   exit 1
fi

cp -v *.cgi *.html .htaccess $DIR

# Patch in the path to chrootperl
perl -e "while(<>) {s/%%DEST%%/\$ENV{'DEST'}/g; print;}"  perl.cgi >$DIR/perl.cgi

cp test.pdb $SANDBOX/tmp

echo " "
echo " "
if [ $DIR == $DEFDIR ]
then
   me=`whoami`
   echo "You may now access the demo code at http://localhost/~${me}/chrootperltutorial/"
else
   echo "You may now access the demo code at the URL equivalent of $DIR"
fi
echo " "
echo " "


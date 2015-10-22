export SANDBOX=/localhome/localuser/sandbox
./makesandbox.pl -sandbox=$SANDBOX
make clean
make
make install
( cd example/html; ./install.sh $SANDBOX )

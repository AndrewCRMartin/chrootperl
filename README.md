chrootperl
==========

V1.0 (c) 2015, UCL, Dr. Andrew C.R. Martin

`chrootperl` is a small wrapper to perl to allow it to be run in a
chroot'ed sandbox.

Installation
------------

Edit the `chrootperl.cfg` file as required. This allows you to specify:

- the directory you wish to use for your sandbox (`$SANDBOX`)
- any additional executables that you need to be able to run - they
  will all be placed in `$SANDBOX/bin`. `bash` and `perl` will be 
  automatically available (`$EXES`)
- and additional directories that you will need to run your Perl script.
  `/bin`, `/lib` and `/lib64` will be automatically available as well 
  as `/run` which is used to store the Perl script (`$DIRS`)

Now run the `makesandbox.pl` script:

    ./makesandbox.pl

This creates the required directories, copies in the executables and
any libraries that they use.

Now source the config file and compile the chrootperl program:

    source ./chrootperl.cfg
    ./make

Note that you must have sudo permissions to do `chmod` and `chown` and
will be prompted for your password.


Running the program
-------------------

Run the program in the same way that you would run perl on the command line:

    ./chrootperl script.pl arguments

Remember that the perl script can only see within your sandbox, so any
files you need must be copied into the sandbox first.

**NOTE:** The script will remain in the `$SANDBOX/run` directory. You
 will need to delete it manually.


Tests
-----

To test the installation, run the shell scripts in the test sub-directory:

### Test 1

    cd test
    ./runtest1.sh

This runs the perl script `test1.pl` in the sandbox. This script
prints some text and prints the results of `ls /bin`. Depending on
what executables you have installed, results will be something like:

    Hello World
    bash
    cat
    ls
    perl

### Test 2

    cd test
    ./runtest2.sh

This copies the file test2.dat into `$SANDBOX/tmp` and then runs the perl script `test2.pl` in the sandbox, passing it `/tmp/test2.dat` as a parameter. The script simply prints the contents of the file specified on the command line so the results should be the same as the contents of test2.dat:

    one
    two
    three
    four
    five

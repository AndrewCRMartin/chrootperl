#if(open(my $fp, '>', '/run/test.pl.out'))
#{
    print "Hello World\n";
    print `ls /bin`;
#    close $fp;
#}

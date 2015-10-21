#!/usr/bin/perl 
use CGI;
use strict;

$::cgi = CGI->new;
my $script = $::cgi->param('script');
$script = CleanScript($script);

my $tfile = WriteScript($script);
if($tfile eq '')
{
    ErrorDie("Can't write temporary file");
}

#my $infile = "/data/tmp/sandbox/tmp/test2.dat";
#my $result = `perl $tfile $infile`;
my $infile = "/tmp/test2.dat";
my $result = `/home/amartin/git/chrootperl/chrootperl $tfile $infile`;

print $::cgi->header();

print <<__EOF;
<h3>Your script</h3>
<pre>
$script
</pre>

<h3>Temp file</h3>
<pre>
$tfile
</pre>

<h3>Result</h3>
<pre>
$result
</pre>
__EOF

sub CleanScript
{
    my($script) = @_;
    return($script);
}

sub ErrorDie
{
    my ($msg) = @_;
    print $::cgi->header();
    print <<__EOF;
<pre>
$msg
</pre>
__EOF
    exit 1;
}

sub WriteScript
{
    my($script) = @_;
    my $tfile = "/var/tmp/" . $$ . time;
    if(open(my $fh, '>', $tfile))
    {
        print $fh $script;
        close($fh);
        return($tfile);
    }
    return('');
}

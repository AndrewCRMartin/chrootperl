#!/usr/bin/perl
use strict;

%::jobs = ();

my $user      = 'localuser';
my @jobnames  = ('perl'    , 'perl.cgi');
#my @params    = ('/var/tmp', '');
my @params    = ('hello', '');
my $timeLimit = 10;

while(<>)
{
    KillLongJobs($user, \@jobnames, \@params, $timeLimit);
    sleep 2;
}

sub KillLongJobs
{
    my($user, $aJobnames, $aParams, $timeLimit) = @_;

    my $jobData = GetJobData($user, $aJobnames, $aParams);
    print $jobData;

    _killTheLongOnes($jobData, $timeLimit);
}

sub _killTheLongOnes
{
    my ($jobData, $timeLimit) = @_;

    my @jobs = split(/\n/, $jobData);
    foreach my $job (@jobs)
    {
        my @fields = split(/\s+/, $job);
        my $jobID = $fields[0];
        if(defined($::jobs{$jobID}))
        {
            if((time() - $::jobs{$jobID}) > $timeLimit)
            {
                print "KILL $jobID\n";
                delete $::jobs{$jobID};
            }
        }
        else
        {
            $::jobs{$jobID} = time();
        }
    }
}

sub GetJobData
{
    my($user, $aJobnames, $aParams) = @_;
    my $data = '';
    for(my $jobCount=0; $jobCount<scalar(@$aJobnames); $jobCount++)
    {
        my $jobname  = $$aJobnames[$jobCount];
        my $jobparam = $$aParams[$jobCount];

        my $grepString = "grep $jobname";
        if($jobparam ne '')
        {
            $grepString .= " | grep $jobparam";
        }

        my $result = `ps -U $user -u $user www | $grepString | grep -v sh | grep -v grep`;
        $data .= $result;
    }

    return($data);
}

#!/usr/bin/perl -s
#*************************************************************************
#
#   Program:    killer
#   File:       killer.pl
#   
#   Version:    V1.1
#   Date:       15.01.19
#   Function:   Kills long running jobs according to patterns specified
#               at the top of the code
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2017-2019
#   Author:     Dr. Andrew C. R. Martin
#   Address:    Institute of Structural and Molecular Biology
#               Division of Biosciences
#               University College
#               Gower Street
#               London
#               WC1E 6BT
#   EMail:      andrew@bioinf.org.uk
#               
#*************************************************************************
#
#   This program is not in the public domain, but it may be copied
#   according to the conditions laid out in the accompanying file
#   COPYING.DOC
#
#   The code may be modified as required, but any modifications must be
#   documented so that the person responsible can be identified. If 
#   someone else breaks this code, I don't want to be blamed for code 
#   that does not work! 
#
#   The code may not be sold commercially or included as part of a 
#   commercial product except as described in the file COPYING.DOC.
#
#*************************************************************************
#
#   Description:
#   ============
#   Designed for use with the example Perl tutorial, this program sits
#   and kills jobs that have been running for longer than a specified
#   time.
#
#*************************************************************************
#
#   Usage:
#   ======
#   ./killer.pl (probably as root)
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   18.01.17   Original
#   V1.1   15.01.19   Remove leading and trailing spaces from jobs
#
#*************************************************************************
use strict;
#*************************************************************************
# CONFIGURATION
# ------------
# User with jobs to kill
my $user      = (defined($::u))?$::u:'apache';
#my $user      = 'localuser';

# Executables to kill
my @jobnames  = ('perl.*/run/.*/tmp/test.pdb', 'practicals/perl/perl.cgi');
#my @jobnames  = ('perl.*hello.*sleep', 'perl.cgi');

# Time to allow a job to run
my $timeLimit = 5;

#*************************************************************************
%::jobs = ();

#*************************************************************************
while(1)
{
    KillLongJobs($user, \@jobnames, $timeLimit);
    sleep 5;
}

#*************************************************************************
sub KillLongJobs
{
    my($user, $aJobnames, $timeLimit) = @_;

    my $jobData = GetJobData($user, $aJobnames);
    if(defined($::d) && ($jobData ne ''))
    {
        print "Found jobs:\n";
        print "$jobData\n";
    }

    _killTheLongOnes($jobData, $timeLimit);
}

#*************************************************************************
sub _killTheLongOnes
{
    my ($jobData, $timeLimit) = @_;

    my @jobs = split(/\n/, $jobData);
    foreach my $job (@jobs)
    {
        $job =~ s/^\s+//;
        $job =~ s/\s+$//;

        my @fields = split(/\s+/, $job);
        my $jobID = $fields[0];
        if(defined($::jobs{$jobID}))
        {
            if((time() - $::jobs{$jobID}) > $timeLimit)
            {
                my $exe = "kill -9 $jobID";
                if(defined($::d))
                {
                    print "Killing job: $jobID\n";
                }
                `$exe`;
                delete $::jobs{$jobID};
            }
        }
        else
        {
            $::jobs{$jobID} = time();
        }
    }
}

#*************************************************************************
sub GetJobData
{
    my($user, $aJobnames) = @_;
    my $data = '';
    for(my $jobCount=0; $jobCount<scalar(@$aJobnames); $jobCount++)
    {
        my $jobname  = $$aJobnames[$jobCount];

        my $grepString = "grep $jobname";

        my $result = `ps -U $user -u $user www | $grepString | grep -v sh | grep -v grep`;
        $data .= $result;
    }

    return($data);
}

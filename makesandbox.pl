#!/usr/bin/perl
#*************************************************************************
#
#   Program:    makesandbox
#   File:       makesandbox.pl
#   
#   Version:    V1.0
#   Date:       20.10.15
#   Function:   Create a sandbox for use with chroot
#   
#   Copyright:  (c) Dr. Andrew C. R. Martin, UCL, 2015
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
#
#*************************************************************************
#
#   Usage:
#   ======
#
#*************************************************************************
#
#   Revision History:
#   =================
#   V1.0   20.10.15  Original
#*************************************************************************
# Add the path of the executable to the library path
use FindBin;
use Cwd qw(abs_path);
use lib abs_path("$FindBin::Bin/perllib/lib");

use strict;
use config;

# Read the confiuration file
my %config = config::ReadConfig('chrootperl.cfg');

# Collect config values
my $sandbox = $config{'SANDBOX'};
my $user    = $config{'USER'};
my $dirs    = $config{'DIRS'};
my @exes    = ParseExes($config{'EXES'});

# Add essential executables
push @exes, '/bin/bash';
push @exes, '/usr/bin/perl';

# Do the work
MakeDirectories($sandbox, $dirs);
CopyExecutables($sandbox, @exes);
CopyLibraryFiles($sandbox, @exes);

#*************************************************************************
#>@exes = ParseExes($exeList)
# ---------------------------
# Take the comma-separated list of executables and split into a list
sub ParseExes
{
    my($exeList) = @_;
    return(split(/\,/, $exeList));
}

#*************************************************************************
#>MakeDirectories($sandbox, $dirs)
# --------------------------------
# Create directories for the sandbox
#
# 20.10.15 Original   By: ACRM
sub MakeDirectories
{
    my($sandbox, $dirs) = @_;
    my $alldirs = "bin,lib64,lib,run"; # Essential directories
    if(length($dirs))                  # Append any other directories
    {
        $alldirs .= ",$dirs";
    }

    # Create the directories
    `mkdir -p $sandbox`;
    `mkdir -p $sandbox/{$alldirs}`;
}

#*************************************************************************
#>CopyExecutables($sandbox, @exes)
# --------------------------------
# Copy the executables into the sandbox
#
# 20.10.15 Original   By: ACRM
sub CopyExecutables
{
    my($sandbox, @exes) = @_;

    foreach my $exe (@exes)
    {
        `cp -v $exe $sandbox/bin`;
    }
}

#*************************************************************************
#>CopyLibraryFiles($sandbox, @exes)
# ---------------------------------
# Find which libraries are used by the executables and copy them in
#
# 20.10.15 Original   By: ACRM
sub CopyLibraryFiles
{
    my($sandbox, @exes) = @_;
    foreach my $exe (@exes)
    {
        my $ldd = `ldd $exe`;
        doCopyLibraryFiles($ldd, $sandbox);
    }
}

#*************************************************************************
#>sub doCopyLibraryFiles($ldd, $sandbox)
# --------------------------------------
# Does the work of parsing the results from ldd and copying in the 
# libraries
#
# 20.10.15 Original   By: ACRM
sub doCopyLibraryFiles
{
    my($ldd, $sandbox) = @_;

    my @lines = split(/\n/, $ldd);
    foreach my $line (@lines)
    {
        $line =~ s/.*=>\s*//;   # Remove up to =>
        $line =~ s/\(.*\)//;    # Remove anything in ()
        $line =~ s/^\s+//;      # Remove leading spaces
        if(length($line))
        {
            if($line =~ /lib64/)
            {
                `cp $line $sandbox/lib64`;
            }
            else
            {
                `cp $line $sandbox/lib`;
            }
        }
    }
}

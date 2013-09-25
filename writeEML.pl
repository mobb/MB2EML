#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Std;
use MB2EML::EML;
use MB2EML::Metabase;
use XML::LibXML;

# Default values for arguments
my $databaseName = "sbc_metabase";
my $datasetId    = '99999';

my $eml;
my $emlDoc;
my $endId;
my $errFilename;
my $idsRef; 
my $mb;
my $outFilename;
my $startId;

# print help info and exit
our $opt_h; 
# name of output directory
our $opt_d; 
# Check EML document validity with XML Schema
our $opt_v;
# run KNB EMLparser
our $opt_p;
# run with/without verbose
our $opt_x;

sub usage {
    print "writeel.pl - write EML documents from Metabase\n\n";
    print "Usage: \n";
    print "mb2eml.pl [options] database datasetID\n\n";
    print "Options: \n";
    print "-d \toutput directory for generated EML docuemnts . If this option is specified,\n";
    print "   \tthen a file is created for each datasetId with the name format of \"<datasetName>-<datasetId>.xml\"\n";
    print "   \tfor example, \"mcr_metabase-10.xml\". If this option is not specified, then all output will be sent to stdout.\n";
    print "-p \tcheck the generated EML document with the KNB \"runParser\" program \n";
    print "-v \trun in verbose mode.\n";
    print "-x \tcheck the validity of the generated EML document against the EML XML Schema.\n\n";
    print "The argument \"datasetID can be specified as one of the following:\n\n";
    print "   \to  a single integer, i.e. \"10\".\n";
    print "   \to  a range of integers, i.e. \"10-20\"\n";
    print "   \to  the keyword \"all\", meaning all datasetIds for the specified databaseName.\n\n";
    print "For example, the command:\n\n";
    print "   \t./writeEML.pl mcr_metabase 10-20 -v\n\n";
    print "will create EML documents from the \"mcr_metabase\" database schema for all document IDs between 10 and 20, with verbose mode on.\n";
}

# Get command line flags
getopts('hpvxd:');

$opt_h = 0,  if (not defined $opt_h);
$opt_p = 0,  if (not defined $opt_p);
$opt_v = 0,  if (not defined $opt_v);
$opt_x = 0,  if (not defined $opt_x);

if ($opt_h) {
    usage();
    exit;
}

# If no command line arguments are passed in, then print usage info and exit
if ($#ARGV == -1 ) {
    usage();
    exit;
}

if (defined $opt_d) {
    if (not -d $opt_d) {
        die "Error: output directory \"$opt_d\" does not exist.\n";
    }
}

$databaseName = $ARGV[0]; 

if ($#ARGV > 0 ) {
    # datasetId can be specified as an integer, i.e. '10' or a range of integers, i.e. '10-20', or 'all'
    $datasetId  = $ARGV[1]; 
} else {
    $datasetId = 'all';
}

$mb = MB2EML::Metabase->new({ databaseName => $databaseName });
$idsRef = $mb->searchDatasetIds();
# Free object and db connection.
undef $mb;

# Was datasetId specified on command line? If not, then use all datasetIds in the database.
if ($datasetId =~ /(\d+)-(\d+)/) {
    $startId = $1;
    $endId = $2;
} elsif ($datasetId eq "all") {
    $startId = @$idsRef[0];
    $endId = @$idsRef[-1];
} elsif ($datasetId =~ /(\d+)/) {
    $startId = $1;
    $endId = $1;
} else {
    warn "Invalid datasetId: $datasetId\n";
    usage();
    exit;
}

for my $id (@$idsRef) {
    if ($id >= $startId && $id <= $endId) {

        if (defined $opt_d) {
            $errFilename = $opt_d . "/" . $databaseName . "-" . $id . ".err";
            open STDERR, ">", $errFilename;
        }

        # Create a new EML object that will be used to assemble the Metabase data into EML
        eval {
            $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $id} );
        };

        if ($@) {
            print STDERR $id . ": Error initializing EML document: $@\n";
        } 

        # Write out the EML object as XML
        # $opt_v = 1 causes schema validation against the eml.xsd to be performed
        # $opt_x = 1 causes the KNB EML parser to be run
        eval {
            $emlDoc = $eml->writeXML(validate => $opt_p, runEMLParser => $opt_x, verbose => $opt_v);
        };

        if ($@) {
            print STDERR $id . ": Error writing EML document: $@\n";
        } 

        if (defined $opt_d) {
            $outFilename = $opt_d . "/" . $databaseName . "-" . $id . ".xml";

            if ($opt_v) {
                print "Writing document $outFilename...\n";
            }

            open FILE, ">", $outFilename or die $!;
            print FILE $emlDoc;
            close FILE;
            close STDERR;
        } else {
            print $emlDoc;
        }
    }
    undef $eml;
}

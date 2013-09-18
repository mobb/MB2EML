#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Std;
use MB2EML::EML;
use XML::LibXML;

if ($#ARGV <  2 ) {
    print "usage: mb2eml.pl database datasetID [validate runParser verbose\n";
    exit;
}

my $databaseName = $ARGV[0];
my $datasetId    = $ARGV[1];
my $validate     = $ARGV[2];
my $runEMLParser = $ARGV[3];
my $verbose      = $ARGV[4];

# Create a new EML object that will be used to assemble the Metabase data into EML
my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );

# Write out the EML object as XML
# $valide = 1 causes schema validation against the eml.xsd to be performed
# $runEMLParser = 1 causes the KNB EML parser to be run
my $output = $eml->writeXML(validate => $validate, runEMLParser => $runEMLParser, verbose => $verbose);

print $output;

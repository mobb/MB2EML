#!/usr/bin/env perl

use strict;
use Getopt::Std;
use MB2EML::EML;
use XML::LibXML;

my $validate;

if ($#ARGV != 1 ) {
    print "usage: mb2eml.pl database datasetID \n";
    exit;
}

my $databaseName = $ARGV[0];
my $datasetId    = $ARGV[1];

# Create a new EML object that will be used to assemble the Metabase data into EML
my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );

# Write out the EML object as XML
# $valide = 1 causes schema validation against the eml.xsd to be performed
# $runEMLParser = 1 causes the KNB EML parser to be run
my $output = $eml->writeXML($validate = 1, runEMLParser => 1);

print $output;

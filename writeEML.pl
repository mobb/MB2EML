#!/usr/bin/env perl

use strict;
#use lib '/Users/peter/Projects/MSI/LTER/MB2EML/MB2EML';
use MB2EML::EML;
use XML::LibXML;

my $validate;

# MCR LTER dataset ids: 99002 99016 99005 996002
#$datasetId = 99016;
#$databaseName = "mcr_metabase";

# SBC LTER dataset ids: 99013 99021 99024
my $datasetId = 99024;
my $databaseName = "sbc_metabase";

# Create a new EML object that will be used to assemble the Metabase data into EML
my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );

# Write out the EML object as XML
# $valide = 1 causes schema validation against the eml.xsd to be performed
# $runEMLParser = 1 causes the KNB EML parser to be run
my $output = $eml->writeXML($validate = 1, runEMLParser => 0);

print $output;

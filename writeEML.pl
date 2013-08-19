#!/usr/bin/env perl

use lib '/Users/peter/Projects/MSI/LTER/MB2EML/MB2EML';
use MB2EML::EML;
use XML::LibXML;

my $validate;

# MCR LTER dataset ids: 99002 99016 99005 996002
#$datasetId = 99016;
#$databaseName = "mcr_metabase";

# SBC LTER dataset ids: 99013 99021 99024
$datasetId = 99021;
$databaseName = "sbc_metabase";

# Create a new EML object that will be used to assemble the Metabase data into EML
my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );

# Write out the EML object as XML
my $output = $eml->writeXML($validate = 1);

print $output;

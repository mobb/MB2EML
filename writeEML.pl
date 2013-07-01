#!/usr/bin/env perl

use lib '/Users/peter/Projects/MSI/LTER/MB2EML';
use EML;

$dataSetId = 99013;
#$databaseName = "mcr_metabase";
$databaseName = "sbc_metabase";

# Create a new EML object that will be used to assemble the Metabase data into EML
my $eml = EML->new({ databaseName => $databaseName });

# Write out the EML object as XML
$eml->writeXML($dataSetId, 'eml');

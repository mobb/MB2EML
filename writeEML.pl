#!/usr/bin/env perl

use lib '/Users/peter/Projects/MSI/LTER/MB2EML/MB2EML';
use MB2EML::EML;
use XML::LibXML;

# MCR LTER dataset ids: 99002 99016 99005 996002
#$datasetId = 99016;
#$databaseName = "mcr_metabase";

# SBC LTER dataset ids: 99013 99021 99024
$datasetId = 99021;
$databaseName = "sbc_metabase";

# Create a new EML object that will be used to assemble the Metabase data into EML
my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );

# Write out the EML object as XML
my $output = $eml->writeXML();

#print $output;

my $doc = XML::LibXML->load_xml(string => $output, { no_blanks => 1 });

#$doc = XML::LibXML->new->parse_file($url);

print $doc->toString(1);

# Validate the XML using a local file
$xmlschema = XML::LibXML::Schema->new( location => 'eml-2.1.1/eml.xsd');

# Validate the XML using a URL. Currently the URLs eml.xsd are on secure sites (https).
# Browsers can easily read these files because they know how to obtain an SSL certificate,
# but Perl LibXML doesn't know how to do this, so these files can't be downloaded.
# The following URLs are 
#$xmlschema = XML::LibXML::Schema->new( location => 'https://nis.lternet.edu/nis/schemas/eml/eml-2.1.1/eml.xsd' );
#$xmlschema = XML::LibXML::Schema->new( location => 'https://code.ecoinformatics.org/code/eml/tags/RELEASE_EML_2_1_1/eml.xsd' );
#$xmlschema = XML::LibXML::Schema->new( location => 'eml.xsd' );

$valid = $xmlschema->validate( $doc );

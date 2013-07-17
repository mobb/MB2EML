#!/usr/bin/env perl

use lib '/Users/peter/Projects/MSI/LTER/MB2EML/MB2EML';
use MB2EML::EML;
use XML::LibXML;

# MCR LTER dataset ids: 99002 99016 99005 996002
#$dataSetId = 996002;
#$databaseName = "mcr_metabase";

# SBC LTER dataset ids: 99013 99021 99024
$dataSetId = 99013;
$databaseName = "sbc_metabase";

# Create a new EML object that will be used to assemble the Metabase data into EML
my $eml = MB2EML::EML->new({ databaseName => $databaseName });

# Write out the EML object as XML
my $output = $eml->writeXML($dataSetId);

my $doc = XML::LibXML->load_xml(string => $output, { no_blanks => 1 });

#$doc = XML::LibXML->new->parse_file($url);

print $doc->toString(1);

# also allow http://nis.lternet.edu/schemas/EML/eml-2.1.1/eml.xsd"
$xmlschema = XML::LibXML::Schema->new( location => 'eml-2.1.1/eml.xsd');
#$xmlschema = XML::LibXML::Schema->new( string => "http://sbc.lternet.edu/external/InformationManagement/EML_210schema/eml.xsd" );
#eval { $xmlschema->validate( $doc ); };
$valid = $xmlschema->validate( $doc );

#!/usr/bin/perl

use MB2EML::Metabase;  # What you're testing.
use MB2EML::EML;
#use Test::Simple tests => 5;
use Test::More 'no_plan';
#use Test;

my $databaseName = "sbc_metabase";
my $element;
my $mb = MB2EML::Metabase->new({ databaseName => $databaseName});

print "Performing unit tests for mb2eml...";
ok( defined($mb->schema), 'initialized Metabase object' );

# use thie to show what output is like if tests are failed:: my $datasetId = '99000';
my $attributeId;
my $datasetId = '10';
my $entityId;

ok ( defined($mb->searchAbstract($datasetId, $entityId=1)), 'fetched data for "abstract" for dataset: ' . $datasetId . ', entity: ' . $entityId);
ok ( defined($mb->searchAccess($datasetId, $entityId=0)),   'fetched data for "access" for dataset: ' . $datasetId . ', entity: ' . $entityId);

# Uncomment this line when the vw_eml_alternateidentifier view is created
ok ( defined($mb->searchAlternateIdentifier($datasetId, $entityId)), 'fetched data for "alternateidentifier" for dataset: ' . $datasetId);

my $arrRef = $mb->searchAssociatedParties($datasetId);
ok ( scalar @$arrRef > 0, 'fetched data for "associated parties" for dataset: ' . $datasetId);

$arrRef = $mb->searchAttributeList($datasetId, $entityId=1);
ok ( scalar @$arrRef> 0, 'fetched data for "attributeList" for dataset: ' . $datasetId . ', entity: ' . $entityId);
ok ( defined($mb->searchContacts($datasetId)), 'fetched data for "contacts" for dataset: ' . $datasetId);

$arrRef = $mb->searchCreators($datasetId);
ok ( scalar @$arrRef > 0, 'fetched data for "creators" for dataset: ' . $datasetId);
ok ( defined($mb->searchDistribution($datasetId)), 'fetched data for "distribution" for dataset: ' . $datasetId);

$arrRef = $mb->searchEntities($datasetId);
ok ( scalar @$arrRef > 0, 'fetched data for "entities" for dataset: ' . $datasetId);

$arrRef = $mb->searchGeographicCoverage($datasetId, $entityId=0, $attributeId=0);
ok ( scalar @$arrRef > 0, 'fetched data for "geographic coverage" for dataset: ' . $datasetId . ', entityId: ' . $entityId);

ok ( defined($mb->searchIntellectualRights($datasetId)), 'fetched data for "intellectual rights" for dataset: ' . $datasetId);

$arrRef = $mb->searchKeywords($datasetId, $entityId=1);
ok ( scalar @$arrRef > 0, 'fetched data for "keywords" for dataset: ' . $datasetId . ', entityId: ' . $entityId);

ok ( defined($mb->searchLanguage($datasetId)), 'fetched data for "language" for dataset: ' . $datasetId);

$arrRef = $mb->searchMethods($datasetId, $entityId=0, $columnId=0);
ok ( scalar @$arrRef > 0, 'fetched data for "methods" for dataset: ' . $datasetId . ', entityId: ' . $entityId . ', columnId: ' . $columnId);

ok ( defined($mb->searchPhysical($datasetId, $entityId=1)), 'fetched data for "physical" for dataset: ' . $datasetId . ', entityId: ' . $entityId);
ok ( defined($mb->searchProject($datasetId)), 'fetched data for "project" for dataset: ' . $datasetId);
ok ( defined($mb->searchPublisher($datasetId)), 'fetched data for "publisher" for dataset: ' . $datasetId);

$arrRef = $mb->searchTaxonomicCoverage($datasetId, $entityId=0, $columnId=0);
ok ( scalar @$arrRef > 0, 'fetched data for "taxonomic coverage" for dataset: ' . $datasetId . ', entityId: ' . $entityId . ', columnId: ' . $columnId);

$arrRef = $mb->searchTemporalCoverage($datasetId, $entityId=0, $columnId=0);
ok ( scalar @$arrRef > 0, 'fetched data for "temporal coverage" for dataset: ' . $datasetId . ', entityId: ' . $entityId . ', columnId: ' . $columnId);

ok ( defined($mb->searchTitle($datasetId)), 'fetched data for "title" for dataset: ' . $datasetId);

$arrRef = $mb->searchUnitList($datasetId);
ok ( scalar @$arrRef > 0, 'fetched data for "unit list" for dataset: ' . $datasetId);

print "Done performing unit tests for mb2eml...\n";

# Compare a reference docuemnt to a newly created document. The reference document is created from 
# a reference dataset that is only used for testing and is not a 'live' dataset, so it will not be updated and
# can be used for comparison to a newly created document, as the EML output should not change.
# Two types of reference datasets have been created: 1. a dataset with a minimul number of EML elements that
# are used by our LTERs 2. a dataset that has the full compliment of EML elements used by our LTERs.
# The minimal dataset tests whether mb2eml works properly when certain EML data are not present, and the
# full document tests that mb2eml works properly when all data are present.
print "Performing diff of minimal reference document and newly created document (datasetId=$datasetId)...\n";

$databaseName = 'sbc_metabase';
$datasetId = '12';
$refFile = './tests/' . $databaseName . "-" . $datasetId . "-ref.xml";
$newFile = './tests/' . $databaseName . "-" . $datasetId . "-new.xml";

my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );
my $output = $eml->writeXML(validate => 0, runEMLParser => 0);

open (EML_FILE , '>' . $newFile);
print EML_FILE $output;
close (EML_FILE); 

$cmd = ' diff -ub ' . $refFile . ' ' . $newFile;
print "cmd: " . $cmd;
my $lines = eval cmd;
print $lines . "\n";

print "Performing diff of full reference document and newly created document (datasetId=$datasetId)...\n";

my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );
my $output = $eml->writeXML(validate => 0, runEMLParser => 0);

open (EML_FILE , '>tests/sbc-12-new.xml');
print EML_FILE $output;
close (EML_FILE); 

print "Output of diff command: \n";
my $lines = `diff -ub ./tests/sbc-12.xml ./tests/sbc-12-ref.xml`;
print $lines . "\n";

#use String::Diff;
#use String::Diff qw( diff_fully diff diff_merge diff_regexp );# export functions
#use Term::ANSIColor qw( RESET :constants );

#open (REF_FILE, 'tests/sbc-12.xml');
#my @ref = <REF_FILE>;
#close (REF_FILE);

#my @ref2;
#open (REF_FILE, 'tests/foo.xml');
#my @ref2 = <REF_FILE>;
#close (REF_FILE);
#
#my $ind;
#for ($ind= 0; $ind < $#ref; $ind++) {
    #$str1 = $ref[$ind];
    #$str2 = $ref2[$ind];
    #my @strings = ( $str1, $str2);
#
    #my $diff = String::Diff::diff(@strings,
        #remove_open  => RED,
        #remove_close => RESET,
        #append_open  => GREEN,
        #append_close => RESET,
    #);
#
    ##if ($diff->[0] != $diff->[1]) {
        #print $diff->[0], "\n";
        #print $diff->[1], "\n";
    ##}
#}
print "Diff tests done.\n";
print "mb2eml tests done.\n";

__END__

=head1 NAME

mb2eml-test.pl - regression tests for the MB2EML software package

=head1 SYNOPSIS

  ./tests/mb2eml-test.pl 

=head1 DESCRIPTION

The mb2eml-test.pl script runs regression tests for the MB2EML software package. 

These tests are run to verify that changes to the MB2EML software and templates have
not introduced errors in the EML documents that MB2EML creates.

=head2 Unit Tests

The first set of tests that are run are unit tests for each function of the 
MB2EML/Metabase.pm module. Each function is run against a reference dataset.

=head2 System Tests

The second set of tests compare reference EML documents to newly created EML documents.
The reference documents are created from the reference datasets and are stored as
test data. When the tests are run, newly created documents are compared to the reference
ones, and any differences between them are shown.

=head2 Reference datasets

In order to test if chagnes in the software or the database have not caused unintended changes
to the EML docuemnts created, reference datasets are used. The reference datasets are only used
for testing purposes and are only changed when testing requirements change. In contrast, production
datasests can be changed at any time.

Two reference datasets are used: 

=over 4

=item * a dataset with a minimul number of EML elements that
are used by our LTERs 

=item * a dataset that has the full compliment of EML elements used by our LTERs.

=back

The minimal dataset tests whether mb2eml works properly when certain EML data are not present, and the
full document tests that mb2eml works properly when all data are present.

=head1 MAINTENANCE

If MB2EML is updated to write out new EML elements to the documents that it
creates, then the tests should be updated to reflect this. A unit test should
be added for any new routine added to Metabase.pm. Also, the reference datasets
and documents should be updated with any new EML elements.

=head1 AUTHOR

Peter Slaughter "<pslaughter@msi.ucsb.edu>"

=cut


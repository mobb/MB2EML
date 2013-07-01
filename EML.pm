#!/usr/bin/env perl

# Perl module that assembles and serializes EML information to XML

package EML;
use Moose;

use lib '/Users/peter/Projects/MSI/LTER/MB2EML';
use lib '/Users/peter/Projects/MSI/LTER/MB2EML/lib';

use Metabase;

has 'mb' => ( is => 'rw');
has 'databaseName' => ( is => 'rw', required => 1 );

# Initialize a EML object that is used to access Metabase.
# Note: Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing 
sub BUILD {
    my $self = shift;

    $self->mb(Metabase->new({ databaseName => $self->databaseName}));
}

sub getAbstract {
    my $self = shift;
    my $datasetId = shift;

    my $abstract = $self->mb->getAbstract($datasetId);

    return $abstract;
}

sub getAttributeList {
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getAttributeList($datasetId);
}

sub getCreators{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getCreators($datasetId);
}

sub getDatasetTitle{
    my $self = shift;
    my $datasetId = shift;

    my $datasetTitle = $self->mb->getDatasetTitle($datasetId);

    return $datasetTitle;
}

sub getEntities{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getEntities($datasetId);
}

sub getKeywords{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getKeywords($datasetId);
}

sub writeXML {

    use Template;
    my $self = shift;
    my $datasetId = shift;
    my $EMLmodule = shift;
    my $templateName;
    my %templateVars = ();

    #my $tt = Template->new({
    #    CONSTANTS => {
    #        emlVersion => "2.1.1",
    #    } 
    #});
    my $tt = Template->new;

    if ($EMLmodule eq "eml") {
        $templateName = 'eml.tt';
        # Retrieve needed data items from the EML object
        my $abstract = $self->getAbstract($datasetId);
        my @attributeList = $self->getAttributeList($datasetId);
        my @creators = $self->getCreators($datasetId);
        my $datasetTitle = $self->getDatasetTitle($datasetId);
        my @keywords = $self->getKeywords($datasetId);
        my @entities = $self->getEntities($datasetId);
        my $k;

        # Load data items into Template Toolkit arguments
        $templateVars{ 'abstract' } = $abstract;
        $templateVars{ 'attributeList' } = \@attributeList;
        $templateVars{ 'creators' } = \@creators;
        $templateVars{ 'dataset' } = $datasetTitle;
        $templateVars{ 'keywords' } = \@keywords;
        $templateVars{ 'datasetid' } = $datasetId;
        $templateVars{ 'entities' } = \@entities;

        #$str =~ s/\r//g

        #foreach $k (@keywords) {
        #    print "kw: " . $k->keyword . "\n";
        #}
    }
    else {
        die "Please specify an eml-module to render to XML";
    }

    # Fill in the template
    $tt->process($templateName, \%templateVars )
        || die $tt->error;
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

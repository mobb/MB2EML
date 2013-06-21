#!/usr/bin/env perl

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

    #print "eml: dbname: " . $self->databaseName . "\n";
    $self->mb(Metabase->new({ databaseName => $self->databaseName}));
}

sub getCreators{
    my $self = shift;
    my $datasetId = shift;

    #my @creators = $self->mb->getCreatorRows($datasetId);

    return $self->mb->getCreatorRows($datasetId);
}

sub getDatasetTitle{
    my $self = shift;
    my $datasetId = shift;

    my $datasetTitle = $self->mb->getDatasetTitle($datasetId);

    return $datasetTitle;
}

sub getKeywords{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getKeywords($datasetId);
}

sub createXML {

    use Template;
    my $self = shift;
    my $datasetId = shift;
    my $EMLmodule = shift;
    my $templateName;
    my %templateVars = ();

    my $tt = Template->new;

    if ($EMLmodule eq "eml-dataset") {
        $templateName = 'eml-dataset.tt';
        # Retrieve needed data items from the EML object
        my @creators = $self->getCreators($datasetId);
        my $datasetTitle = $self->getDatasetTitle($datasetId);
        my @keywords = $self->getKeywords($datasetId);
        my $k;

        # Load data items into Template Toolkit arguments
        $templateVars{ 'creators' } = \@creators;
        $templateVars{ 'dataset' } = $datasetTitle;
        $templateVars{ 'keywords' } = \@keywords;
        $templateVars{ 'id' } = $datasetId;

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

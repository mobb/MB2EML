#!/usr/bin/env perl

# Perl module that assembles and serializes EML information to XML

package MB2EML::EML;
use Moose;

use lib '/Users/peter/Projects/MSI/LTER/MB2EML';
use lib '/Users/peter/Projects/MSI/LTER/MB2EML/lib';

use MB2EML::Metabase;

has 'mb' => ( is => 'rw');
has 'databaseName' => ( is => 'rw', required => 1 );

# Initialize a EML object that is used to access Metabase.
# Note: Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing 
sub BUILD {
    my $self = shift;

    $self->mb(MB2EML::Metabase->new({ databaseName => $self->databaseName}));
}

sub DEMOLISH {
    my $self = shift;
}

sub getAbstract {
    my $self = shift;
    my $datasetId = shift;

    my $abstract = $self->mb->getAbstract($datasetId);

    return $abstract;
}

sub getAccess{
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;

    return $self->mb->getAccess($datasetId, $entityId);
}

sub getAttributeList {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;

    return $self->mb->getAttributeList($datasetId, $entityId);
}

sub getAssociatedParties{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getAssociatedParties($datasetId);
}

sub getContacts{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getContacts($datasetId);
}

sub getCreators{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getCreators($datasetId);
}

sub getTitle{
    my $self = shift;
    my $datasetId = shift;

    my $title = $self->mb->getTitle($datasetId);

    return $title;
}

sub getDistribution {
    my $self = shift;
    my $datasetId = shift;

    my $distribution = $self->mb->getDistribution($datasetId);

    return $distribution;
}

sub getEntities{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getEntities($datasetId);
}

sub getIntellectualRights {
    my $self = shift;
    my $datasetId = shift;

    my $intellectualRights = $self->mb->getIntellectualRights ($datasetId);

    return $intellectualRights;
}

sub getKeywords{
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getKeywords($datasetId);
}

sub getLanguage{
    my $self = shift;
    my $datasetId = shift;

    my $language = $self->mb->getLanguage($datasetId);

    return $language;
}

sub getPhysical{
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;

    my $language = $self->mb->getPhysical($datasetId, $entityId);

    return $language;
}

sub getProject {
    my $self = shift;
    my $datasetId = shift;

    my $project = $self->mb->getProject($datasetId);

    return $project;
}

sub getPublisher {
    my $self = shift;
    my $datasetId = shift;

    my $publisher = $self->mb->getPublisher($datasetId);

    return $publisher;
}

sub getUnitList {
    my $self = shift;
    my $datasetId = shift;

    return $self->mb->getUnitList($datasetId);
}

sub writeXML {

    use Template;
    my $self = shift;
    my $datasetId = shift;
    my $EMLmodule = shift;
    my $output = '';;
    my $templateName;
    my %templateVars = ();
    my @entities;
    my $entity;
    my $packageId = "knb-lter-" . substr($self->databaseName, 0, index($self->databaseName, '_')) . $datasetId . "0";

    my $tt = Template->new;
    my @attributeList;

    $templateName = 'eml.tt';
    # Retrieve needed data items from the EML object
    my $abstract           = $self->getAbstract($datasetId);
    my $access             = $self->getAccess($datasetId, 0);
    my @associatedParties  = $self->getAssociatedParties($datasetId);
    my @contacts           = $self->getContacts($datasetId);
    my @creators           = $self->getCreators($datasetId);
    my $distribution       = $self->getDistribution($datasetId);
    my $intellectualRights = $self->getIntellectualRights($datasetId);
    my @keywords           = $self->getKeywords($datasetId);
    my $language           = $self->getLanguage($datasetId);
    my $project            = $self->getProject($datasetId);
    my $publisher          = $self->getPublisher($datasetId);
    my $title              = $self->getTitle($datasetId);
    my @unitList           = $self->getUnitList($datasetId);

    # Load data items into Template Toolkit arguments
    $templateVars{'abstract'} = $abstract;
    $templateVars{'access'} = $access;
    $templateVars{'associatedParties'} = \@associatedParties;
    $templateVars{'contacts'} = \@contacts;
    $templateVars{'creators'} = \@creators;
    $templateVars{'dataset'} = { 'title' => $title->title, 'id' => $datasetId} ;
    $templateVars{'distribution'} = $distribution;
    $templateVars{'intellectualRights'} = $intellectualRights;
    $templateVars{'keywords'} = \@keywords;
    $templateVars{'language'} = $language;
    $templateVars{'packageId'} = $packageId;
    $templateVars{'project'} = $project;
    $templateVars{'publisher'} = $publisher;
    $templateVars{'unitList'} = \@unitList;

    # Fetch the entities, which includes top level items common to all entities.
    @entities = $self->getEntities($datasetId);
    for $entity (@entities) {
        $entity->{'access'} = $self->getAccess($datasetId, $entity->sortorder );

        @attributeList = $self->getAttributeList($datasetId, $entity->sortorder );
        $entity->{'attributeList'} = \@attributeList;

        $entity->{'physical'} = $self->getPhysical($datasetId, $entity->sortorder );
    }

    $templateVars{ 'entities' } = \@entities;

    # Fill in the template, sending template output to a text string
    $tt->process($templateName, \%templateVars, \$output )
        || die $tt->error;

    return $output;


}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

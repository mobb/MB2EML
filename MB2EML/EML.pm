#!/usr/bin/env perl

# Perl module that assembles and serializes EML information to XML

package MB2EML::EML;
use Moose;

use lib '/Users/peter/Projects/MSI/LTER/MB2EML';
use lib '/Users/peter/Projects/MSI/LTER/MB2EML/lib';

use MB2EML::Metabase;

has 'abstract'           => ( is => 'rw' );
has 'access'             => ( is => 'rw' );
has 'associatedParties'  => ( is => 'rw' );
has 'contacts'           => ( is => 'rw' );
has 'creators'           => ( is => 'rw' );
has 'databaseName'       => ( is => 'rw', isa => 'Str', required => 1 );
has 'datasetId'          => ( is => 'rw', isa => 'Num' , required => 1);
has 'entities'             => ( is => 'rw');
has 'distribution'       => ( is => 'rw' );
has 'intellectualRights' => ( is => 'rw' );
has 'keywords'           => ( is => 'rw' );
has 'language'           => ( is => 'rw' );
has 'mb'                 => ( is => 'rw');
has 'packageId'          => ( is => 'rw' );
has 'project'            => ( is => 'rw' );
has 'publisher'          => ( is => 'rw' );
has 'title'              => ( is => 'rw' );
has 'unitList'           => ( is => 'rw' );

# Initialize a EML object that is used to access Metabase.
# Note: Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing 
sub BUILD {
    my $self = shift;
    my @entities;
    my $entity;
    my $entitySortOrder;
    my @attributeList;

    $self->mb(MB2EML::Metabase->new({ databaseName => $self->databaseName}));

    # Retrieve needed data items from the EML object
    $self->abstract($self->getAbstract());
    $self->access($self->getAccess($entitySortOrder=0));
    my @associatedParties  = $self->getAssociatedParties();
    $self->associatedParties(\@associatedParties);
    my @contacts           = $self->getContacts();
    $self->contacts(\@contacts);
    my @creators           = $self->getCreators();
    $self->creators(\@creators);
    $self->distribution($self->getDistribution());
    $self->intellectualRights($self->getIntellectualRights());
    my @keywords           = $self->getKeywords();
    $self->keywords(\@keywords);
    $self->language($self->getLanguage());
    $self->project($self->getProject());
    $self->publisher($self->getPublisher());
    $self->title($self->getTitle());
    my @unitList           = $self->getUnitList();
    $self->unitList(\@unitList);

    $self->packageId("knb-lter-" . substr($self->databaseName, 0, index($self->databaseName, '_')) . "." . $self->datasetId . "." . "0");

    # Fetch the entities, which includes top level items common to all entities.
    @entities = $self->getEntities();
    for $entity (@entities) {
        $entity->{'access'} = $self->getAccess($entity->{'sort_order'});
        @attributeList = $self->getAttributeList($entity->{'sort_order'});
        $entity->{'attributeList'} =  \@attributeList;
        $entity->{'physical'} =  $self->getPhysical($entity->{'sort_order'});
    }

    $self->entities(\@entities);
}

sub DEMOLISH {
    my $self = shift;
}

sub getAbstract {
    my $self = shift;

    my $abstract = $self->mb->getAbstract($self->datasetId);

    return $abstract;
}

sub getAccess{
    my $self = shift;
    my $entityId = shift;

    return $self->mb->getAccess($self->datasetId, $entityId);
}

sub getAttributeList {
    my $self = shift;
    my $entityId = shift;

    return $self->mb->getAttributeList($self->datasetId, $entityId);
}

sub getAssociatedParties{
    my $self = shift;

    return $self->mb->getAssociatedParties($self->datasetId);
}

sub getContacts{
    my $self = shift;

    return $self->mb->getContacts($self->datasetId);
}

sub getCreators{
    my $self = shift;

    return $self->mb->getCreators($self->datasetId);
}

sub getTitle{
    my $self = shift;

    my $title = $self->mb->getTitle($self->datasetId);

    return $title;
}

sub getDistribution {
    my $self = shift;

    my $distribution = $self->mb->getDistribution($self->datasetId);

    return $distribution;
}

sub getEntities{
    my $self = shift;

    return $self->mb->getEntities($self->datasetId);
}

sub getIntellectualRights {
    my $self = shift;

    my $intellectualRights = $self->mb->getIntellectualRights ($self->datasetId);

    return $intellectualRights;
}

sub getKeywords{
    my $self = shift;

    return $self->mb->getKeywords($self->datasetId);
}

sub getLanguage{
    my $self = shift;

    my $language = $self->mb->getLanguage($self->datasetId);

    return $language;
}

sub getPhysical{
    my $self = shift;
    my $entityId = shift;

    my $language = $self->mb->getPhysical($self->datasetId, $entityId);

    return $language;
}

sub getProject {
    my $self = shift;

    my $project = $self->mb->getProject($self->datasetId);

    return $project;
}

sub getPublisher {
    my $self = shift;

    my $publisher = $self->mb->getPublisher($self->datasetId);

    return $publisher;
}

sub getUnitList {
    my $self = shift;

    return $self->mb->getUnitList($self->datasetId);
}

sub writeXML {

    use Template;
    my $self = shift;
    my $output = '';;
    my $templateName;
    my %templateVars = ();

    my $tt = Template->new({ RELATIVE => 1 });

    $templateName = './templates/eml.tt';

    # Load data items into Template Toolkit arguments
    $templateVars{'abstract'} = $self->abstract;
    $templateVars{'access'} = $self->access;
    $templateVars{'associatedParties'} = $self->associatedParties;
    $templateVars{'contacts'} = $self->contacts;
    $templateVars{'creators'} = $self->creators;
    $templateVars{'dataset'} = { 'title' => $self->title->title, 'id' => $self->datasetId} ;
    $templateVars{'distribution'} = $self->distribution;
    $templateVars{'intellectualRights'} = $self->intellectualRights;
    $templateVars{'keywords'} = $self->keywords;
    $templateVars{'language'} = $self->language;
    $templateVars{'packageId'} = $self->packageId;
    $templateVars{'project'} = $self->project;
    $templateVars{'publisher'} = $self->publisher;
    $templateVars{'unitList'} = $self->unitList;
    $templateVars{'entities'} = $self->entities;

    # Fill in the template, sending template output to a text string
    $tt->process($templateName, \%templateVars, \$output )
        || die $tt->error;

    return $output;
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

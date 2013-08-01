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
has 'taxonomicCoverage'           => ( is => 'rw' );
has 'temporalCoverage'           => ( is => 'rw' );

# Initialize a EML object that is used to access Metabase.
# Note: Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing 
sub BUILD {
    my $self = shift;
    my @associatedParties;
    my @attributeList;
    my @contacts;
    my @taxonomicCoverage;
    my @temporalCoverage;
    my @creators;
    my @entities;
    my $entity;
    my $entityId;
    my $entitySortOrder;
    my @keywords;
    my @unitList; 

    $self->mb(MB2EML::Metabase->new({ databaseName => $self->databaseName}));

    # Retrieve needed data items from the EML object
    $self->abstract($self->getAbstract());
    $self->access($self->getAccess($entityId=0));

    @associatedParties  = $self->getAssociatedParties();
    $self->associatedParties(\@associatedParties);

    @contacts           = $self->getContacts();
    $self->contacts(\@contacts);

    @creators           = $self->getCreators();
    $self->creators(\@creators);
    $self->distribution($self->getDistribution());
    $self->intellectualRights($self->getIntellectualRights());

    @keywords           = $self->getKeywords();
    $self->keywords(\@keywords);
    $self->language($self->getLanguage());
    $self->project($self->getProject());
    $self->publisher($self->getPublisher());
    # Get temporal coverage at the dataset level, if it exists
    @taxonomicCoverage = $self->getTaxonomicCoverage($entityId=0);
    $self->taxonomicCoverage(@taxonomicCoverage);

    # Get taxonomic coverage at the dataset level, if it exists
    @temporalCoverage = $self->getTemporalCoverage($entityId=0);
    $self->temporalCoverage(@temporalCoverage);

    $self->title($self->getTitle());

    @unitList           = $self->getUnitList();
    $self->unitList(\@unitList);

    $self->packageId("knb-lter-" . substr($self->databaseName, 0, index($self->databaseName, '_')) . "." . $self->datasetId . "." . "0");

    # Fetch the entities. Initially the @entity array contains just the info from the vw_eml_entity view as returned from
    # the getEntity method. Here we loop through this array and for each entity append other elements 
    # ('access', 'attributeList') so that they are easily accessable by the templates.
    @entities = $self->getEntities();
    for $entity (@entities) {
        $entity->{'access'} = $self->getAccess($entity->sort_order);
        @attributeList = $self->getAttributeList($entity->sort_order);
        $entity->{'attributeList'} =  \@attributeList;

        # CUrrently (2013 07 23) the vw_eml_temporalcoverage view only supports one date range per entity
        @temporalCoverage = $self->getTemporalCoverage($entity->sort_order);
        $entity->{'coverage'}->{'temporalcoverage'} = \@temporalCoverage;

        @taxonomicCoverage = $self->getTaxonomicCoverage($entity->sort_order);
        $entity->{'coverage'}->{'taxonomiccoverage'} = \@taxonomicCoverage;

        $entity->{'physical'} =  $self->getPhysical($entity->sort_order);
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


sub getTaxonomicCoverage{
    my $self = shift;
    my $entityId = shift;

    return $self->mb->getTaxonomicCoverage($self->datasetId, $entityId);
}

sub getTemporalCoverage{
    my $self = shift;
    my $entityId = shift;

    return $self->mb->getTemporalCoverage($self->datasetId, $entityId);
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
    my %templateVars;

    my $tt = Template->new({ RELATIVE => 1 });

    $templateName = './templates/eml.tt';

    # Load data items into Template Toolkit arguments
    $templateVars{'abstract'} = $self->abstract;
    $templateVars{'access'} = $self->access;
    $templateVars{'associatedParties'} = $self->associatedParties;
    $templateVars{'contacts'} = $self->contacts;

    #my $tc;
    #foreach $tc ($self->temporalCoverage) {
    #    print $tc;
    #}

    $templateVars{'creators'} = $self->creators;
    $templateVars{'dataset'} = { 'title' => $self->title->title, 
                                 'id' => $self->datasetId, 
                                 'coverage' => {'taxonomiccoverage' => $self->taxonomicCoverage, 
                                                'temporalcoverage' => $self->temporalCoverage }};
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

# Perl module that assembles and serializes EML information to XML

package MB2EML::EML;
use Moose;
use Carp;

use lib '/Users/peter/Projects/MSI/LTER/MB2EML';
use lib '/Users/peter/Projects/MSI/LTER/MB2EML/lib';

use MB2EML::Metabase;

has 'abstract'           => ( is => 'rw', isa => 'Object' );
has 'access'             => ( is => 'rw', isa => 'Object' );
has 'associatedParties'  => ( is => 'rw', isa => 'ArrayRef');
has 'contacts'           => ( is => 'rw', isa => 'ArrayRef');
has 'creators'           => ( is => 'rw', isa => 'ArrayRef' );
has 'databaseName'       => ( is => 'rw', isa => 'Str', required => 1 );
has 'datasetId'          => ( is => 'rw', isa => 'Num' , required => 1);
has 'entities'           => ( is => 'rw', isa => 'ArrayRef');
has 'distribution'       => ( is => 'rw', isa => 'Object' );
has 'intellectualRights' => ( is => 'rw', isa => 'Object' );
has 'keywords'           => ( is => 'rw', isa => 'ArrayRef' );
has 'language'           => ( is => 'rw', isa => 'Object');
has 'mb'                 => ( is => 'rw', isa => 'Object');
has 'packageId'          => ( is => 'rw', isa => 'Str');
has 'project'            => ( is => 'rw', isa => 'Object');
has 'publisher'          => ( is => 'rw', isa => 'Object');
has 'title'              => ( is => 'rw', isa => 'Object');
has 'unitList'           => ( is => 'rw', isa => 'ArrayRef' );
has 'taxonomicCoverage'  => ( is => 'rw', isa => 'ArrayRef' );
has 'temporalCoverage'   => ( is => 'rw', isa => 'ArrayRef' );

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

    @associatedParties = $self->getAssociatedParties();
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
    $self->taxonomicCoverage(\@taxonomicCoverage);

    # Get taxonomic coverage at the dataset level, if it exists
    @temporalCoverage = $self->getTemporalCoverage($entityId=0);
    $self->temporalCoverage(\@temporalCoverage);

    $self->title($self->getTitle());

    @unitList           = $self->getUnitList();
    $self->unitList(\@unitList);

    # Currently (2013 08) we are manually constructing the packageId from the database name and datasetId. In the future,
    # this value will be obtained from Metabase.
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
    my $attribute;
    my @attributeList;

    @attributeList = $self->mb->getAttributeList($self->datasetId, $entityId);

    # Check each numeric type attribute and ensure that a unit value was specified,
    # e.g. a 'Temperature' attribute may have a numbertype 'real' with unit type 'celsius'.
    foreach $attribute (@attributeList) {
        if ($attribute->numbertype) {
            if (not $attribute->unit) {
                warn ("No unit value specified for attribute: " . $attribute->attributeid . ", number type: " . $attribute->numberType . "\n");
            }
        }
    }

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
    my $validate = shift;

    my $doc;
    my $output = '';
    my $templateName;
    my %templateVars;
    my $xmlschema;
    my $valid;

    my $tt = Template->new({ RELATIVE => 1 });

    $templateName = './templates/eml.tt';

    # Load data items into Template Toolkit arguments
    $templateVars{'abstract'} = $self->abstract;
    $templateVars{'access'} = $self->access;
    $templateVars{'associatedParties'} = $self->associatedParties;
    $templateVars{'contacts'} = $self->contacts;
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

    # Create an XML object from the string returned from the template engine. This
    # call will check for well-formedness.
    eval {
        $doc = XML::LibXML->load_xml(string => $output, { no_blanks => 1 });
    };

    if ($@) {
        warn ("Error creating XML document: $@\n");
    } 

    if ($validate) {
        eval {
            $xmlschema = XML::LibXML::Schema->new( location => 'eml-2.1.1/eml.xsd');
            $valid = $xmlschema->validate( $doc );
        };
    }

    if ($@) {
        warn ("Error validating XML document: $@\n");
    } 

    return $doc->toString(1);
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

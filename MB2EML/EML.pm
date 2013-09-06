# Perl module that assembles and serializes EML information to XML

package MB2EML::EML;
use Moose;
use strict;
use Config::Simple;
use File::Temp ();
#use LWP::Simple;
use MB2EML::Metabase;

has 'abstract'           => ( is => 'rw', isa => 'Object' );
has 'access'             => ( is => 'rw', isa => 'Object' );
has 'associatedParties'  => ( is => 'rw', isa => 'ArrayRef');
has 'contacts'           => ( is => 'rw', isa => 'ArrayRef');
has 'creators'           => ( is => 'rw', isa => 'ArrayRef' );
has 'databaseName'       => ( is => 'rw', isa => 'Str', required => 1 );
has 'dataset'            => ( is => 'rw', isa => 'HashRef');
has 'datasetId'          => ( is => 'rw', isa => 'Num' , required => 1);
has 'entities'           => ( is => 'rw', isa => 'ArrayRef');
has 'distribution'       => ( is => 'rw', isa => 'Object' );
has 'geographicCoverage' => ( is => 'rw', isa => 'ArrayRef' );
has 'intellectualRights' => ( is => 'rw', isa => 'Object' );
has 'keywords'           => ( is => 'rw', isa => 'ArrayRef' );
has 'language'           => ( is => 'rw', isa => 'Object');
has 'mb'                 => ( is => 'rw', isa => 'Object');
has 'methods'            => ( is => 'rw', isa => 'ArrayRef');
has 'packageId'          => ( is => 'rw', isa => 'Str');
has 'project'            => ( is => 'rw', isa => 'Object');
has 'publisher'          => ( is => 'rw', isa => 'Object');
has 'title'              => ( is => 'rw', isa => 'Object');
has 'unitList'           => ( is => 'rw', isa => 'ArrayRef' );
has 'taxonomicCoverage'  => ( is => 'rw', isa => 'ArrayRef');
has 'temporalCoverage'   => ( is => 'rw', isa => 'ArrayRef');

# Initialize a EML object that is used to access Metabase.
# Note: Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing 
sub BUILD {
    my $self = shift;
    my $datasetRef;
    my @entities;
    my $entity;
    my $entityId;
    my $entitySortOrder;

    $self->mb(MB2EML::Metabase->new({ databaseName => $self->databaseName}));

    # Initialize attributes, in case they will be used by the methods.
    $self->abstract($self->getAbstract());
    $self->access($self->getAccess($entityId=0));
    $self->associatedParties($self->getAssociatedParties());
    $self->contacts($self->getContacts());
    $self->creators($self->getCreators());

    # Fetch the entities. Initially the @entity array contains just the info from the vw_eml_entity view as returned from
    # the getEntity method. Here we loop through this array and for each entity append other elements 
    # ('access', 'attributeList') so that they are easily accessable by the templates.
    @entities = $self->getEntities();
    for $entity (@entities) {
        $entity->{'access'} = $self->getAccess($entity->sort_order);
        $entity->{'attributeList'} = $self->getAttributeList($entity->sort_order);
        $entity->{'coverage'}->{'geographiccoverage'} = $self->getGeographicCoverage($entity->sort_order);
        $entity->{'methods'} = $self->getMethods($entity->sort_order);
        # CUrrently (2013 07 23) the vw_eml_temporalcoverage view only supports one date range per entity
        $entity->{'coverage'}->{'temporalcoverage'} = $self->getTemporalCoverage($entity->sort_order, 0);
        $entity->{'coverage'}->{'taxonomiccoverage'} = $self->getTaxonomicCoverage($entity->sort_order, 0);
        $entity->{'physical'} =  $self->getPhysical($entity->sort_order);
    }

    $self->entities(\@entities);
    $self->distribution($self->getDistribution());
    $self->geographicCoverage($self->getGeographicCoverage($entityId=0));
    $self->intellectualRights($self->getIntellectualRights());
    $self->keywords($self->getKeywords());
    $self->language($self->getLanguage());
    $self->methods($self->getMethods($entityId=0));
    # Currently (2013 08) we are manually constructing the packageId from the database name and datasetId. In the future,
    # this value will be obtained from Metabase.
    $self->packageId("knb-lter-" . substr($self->databaseName, 0, index($self->databaseName, '_')) . "." . $self->datasetId . "." . "0");
    $self->project($self->getProject());
    $self->publisher($self->getPublisher());
    $self->taxonomicCoverage($self->getTaxonomicCoverage($entityId=0, 0));
    $self->temporalCoverage($self->getTemporalCoverage($entityId=0, 0));
    $self->title($self->getTitle());
    $self->unitList($self->getUnitList());

    # Construct a 'dataset' hash that contains all info we are using in eml-dataset. This
    # is done for ease of use so that methods such as 'writeXML' don't have to know
    # the structure of the eml-dataset module (as all the structure is built here).
    my %dataset = ();
    $dataset{'abstract'} = $self->abstract;
    $dataset{'access'} = $self->access;
    $dataset{'associatedParties'} = $self->associatedParties;
    $dataset{'contacts'} = $self->contacts;
    $dataset{'coverage'} = ( { 'geographiccoverage'  => $self->geographicCoverage,
                               'taxonomiccoverage' => $self->taxonomicCoverage,
                               'temporalcoverage' => $self->temporalCoverage });
    $dataset{'creators'} = $self->creators;
    $dataset{'distribution'} = $self->distribution;
    $dataset{'entities'} = $self->entities;
    $dataset{'id'} = $self->datasetId;
    $dataset{'intellectualRights'} = $self->intellectualRights;
    $dataset{'keywords'} = $self->keywords;
    $dataset{'language'} = $self->language;
    $dataset{'methods'} = $self->methods;
    $dataset{'packageId'} = $self->packageId;
    $dataset{'project'} = $self->project;
    $dataset{'publisher'} = $self->publisher;
    $dataset{'title'} = $self->title->title;
    $self->dataset(\%dataset);

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
    my $attributeListRef;

    $attributeListRef = $self->mb->getAttributeList($self->datasetId, $entityId);

    # Check each numeric type attribute and ensure that a unit value was specified,
    # e.g. a 'Temperature' attribute may have a numbertype 'real' with unit type 'celsius'.
    foreach $attribute (@$attributeListRef) {
        if ($attribute->numbertype) {
            if (not $attribute->unit) {
                warn ("No unit value specified for attribute: " . $attribute->attributeid . ", number type: " . $attribute->numberType . "\n");
            }
        }

        # Check each attribute to see if it has a taxomicCoverage element, and if so, append it to that attribute.
        my $taxonomicCoverageRef = $self->mb->getTaxonomicCoverage($self->datasetId, $entityId, $attribute->column_sort_order);
        # Check length of the returned list of tax. coverage
        if (scalar @{ $taxonomicCoverageRef } > 0) {
            $attribute->{'coverage'}->{'taxonomiccoverage'} = $taxonomicCoverageRef;
        } else {
            $attribute->{'coverage'}->{'taxonomiccoverage'} = {};
        }

        # Currently EML attribute elements are not using geographic coverages or temporal coverages, but 
        # we need to create empty hashes for them so that the template 'foreach' has sometime to
        # loop over (even though it's empty)
        $attribute->{'coverage'}->{'geographiccoverage'} = {};
        $attribute->{'coverage'}->{'temporalcoverage'} = {};
    }

    #return $self->mb->getAttributeList($self->datasetId, $entityId);
    return $attributeListRef;
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


sub getGeographicCoverage{
    my $self = shift;
    my $entityId = shift;

    return $self->mb->getGeographicCoverage($self->datasetId, $entityId);
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

sub getMethods {
    my $self = shift;
    my $entityId = shift;

    #my $method;
    #my @methods;

    #@methods = $self->mb->getMethods($self->datasetId, $entityId);

    #for $method (@methods) {
    #    print "getMethods method: " . $method->methodstep . "\n";
    #}

    return $self->mb->getMethods($self->datasetId, $entityId);
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

sub getTaxonomicCoverage{
    my $self = shift;
    my $entityId = shift;
    my $columnId = shift;

    return $self->mb->getTaxonomicCoverage($self->datasetId, $entityId, $columnId);
}

sub getTemporalCoverage{
    my $self = shift;
    my $entityId = shift;
    my $columnId = shift;

    return $self->mb->getTemporalCoverage($self->datasetId, $entityId, $columnId);
}

sub getTitle{
    my $self = shift;

    my $title = $self->mb->getTitle($self->datasetId);

    return $title;
}

sub getUnitList {
    my $self = shift;

    return $self->mb->getUnitList($self->datasetId);
}

sub writeXML {

    use Template;
    my $self = shift;
    my $validate = shift;
    my $runParser = shift;

    my $EMLlocation;
    my $doc;
    my $output = '';
    my $templateName;
    my %templateVars;
    my $xmlschema;
    my $valid;

    my $tt = Template->new({ RELATIVE => 1 });

    $templateName = './templates/eml.tt';

    # Load data items into Template Toolkit arguments
    # Each of the following variables are top level EML elements, and 'eml' is
    # not included in the name, i.e. 'eml.packageId', 'eml.dataset', ...
    $templateVars{'packageId'} = $self->packageId;
    $templateVars{'dataset'} = $self->dataset;
    $templateVars{'additionalMetadata'}{'unitList'} = $self->unitList;

    # Fill in the template, sending template output to a text string
    $tt->process($templateName, \%templateVars, \$output )
        || die $tt->error;

    # Create an XML object from the string returned from the template engine. This
    # call will check for well-formedness.
    eval {
        $doc = XML::LibXML->load_xml(string => $output, { no_blanks => 1 });
    };

    if ($@) {
        print STDERR $self->datasetId . " : Error creating XML document: $@\n";
        die $self->datasetId . ": Processing halted because XML document is not valid.\n";
    } 

    if ($validate || $runParser) {
        # Load config file
        my $cfg = new Config::Simple('config/mb2eml.ini');
        $EMLlocation = $cfg->param('EMLlocation');
        if (! defined $EMLlocation) {
            print STDERR "The location of the EML distribution is not defined. Please enter the parameter \"EMLlocation\" into the config/mb2eml.ini file.\n";
        } 
    }

    if ($validate) {
        if (! defined $EMLlocation) {
            print STDERR "Unable to perform validation with eml.xsd because the location of the EML distribution is unknown.\n";
        } else {
            eval {
                #my $EMLlocation  = 'http://sbc.lternet.edu/external/InformationManagement/EML_211_schema/eml.xsd';
                my $EML_XSD = $EMLlocation . "/eml.xsd";
                $xmlschema = XML::LibXML::Schema->new( location => $EML_XSD);
                $valid = $xmlschema->validate( $doc );
            };
            if ($@) {
                print STDERR $self->datasetId . ": Error validating XML document: $@\n";
            } 
        }
    }

    # Run the EMLParser against the newly created document to check that all references are correct.
    if ($runParser) {
        if (! defined $EMLlocation) {
            print STDERR "Unable to run EML Parser because the location of the EML distribution is unknown.\n";
        } else {
            my $tmp = File::Temp->new();
            my $filename = $tmp->filename;
    
            open my $out, '>', $filename;
            print {$out} $doc->toString();
            close $out;
            my $cmd = "java -cp " . $EMLlocation . "/lib/*:" . $EMLlocation . "/lib/apache/* org.ecoinformatics.eml.EMLParser -q " . $EMLlocation . "/lib/config.xml " . $filename;
            my $result = `$cmd 2>&1`;
    
            # The return value is set in $?; this value is the exit status of the command as returned by the 'wait' call; 
            # to get the real exit status of the command you have to shift right by 8 the value of $? ($? >> 8). 
            if (($? >> 8)) {
                print STDERR $self->datasetId . ": $result\n";
            }
        }
    }

    return $doc->toString(1);
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

# Perl module that assembles and serializes EML information to XML

package MB2EML::EML;
use Moose;
use strict;
use warnings;
use Config::Simple;
use File::Temp ();
use XML::LibXML;
#use LWP::Simple;
use MB2EML::Metabase;

# Attributes of the Metabase object
has 'abstract'           => ( is => 'rw', isa => 'Object' );
has 'access'             => ( is => 'rw', isa => 'Object' );
has 'alternateIdentifier' => ( is => 'rw', isa => 'Object' );
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
    my $columnId;
    my $datasetRef;
    my $entitiesRef;
    my $entity;
    my $entityId;
    my $entitySortOrder;

    $self->mb(MB2EML::Metabase->new({ databaseName => $self->databaseName}));

    # Initialize attributes, in case they will be used by the methods.
    $self->abstract($self->getAbstract());
    $self->access($self->getAccess($entityId=0));
    # Uncomment this line when the vw_eml_alternateidentifier view is created
    #$self->alternateIdentifier($self->getAlternateIdentifier($entity=0));
    $self->associatedParties($self->getAssociatedParties());
    $self->contacts($self->getContacts());
    $self->creators($self->getCreators());

    # Fetch the entities. Initially the @entity array contains just the info from the vw_eml_entity view as returned from
    # the getEntity method. Here we loop through this array and for each entity append other elements 
    # ('access', 'attributeList') so that they are easily accessable by the templates.
    $entitiesRef = $self->getEntities();
    for $entity (@$entitiesRef) {
        $entity->{'access'} = $self->getAccess($entity->sort_order);
        # Uncomment this line when the vw_eml_alternateidentifier view is created
        #$entity->{'alternateIdentifier'} = $self->getAlternateIdentifier($entity->sort_order);
        $entity->{'attributeList'} = $self->getAttributeList($entity->sort_order);
        $entity->{'coverage'}->{'geographiccoverage'} = $self->getGeographicCoverage($entity->sort_order);
        $entity->{'methods'} = $self->getMethods($entity->sort_order, $columnId=0);
        # CUrrently (2013 07 23) the vw_eml_temporalcoverage view only supports one date range per entity
        $entity->{'coverage'}->{'temporalcoverage'} = $self->getTemporalCoverage($entity->sort_order, $columnId=0);
        $entity->{'coverage'}->{'taxonomiccoverage'} = $self->getTaxonomicCoverage($entity->sort_order, $columnId=0);
        $entity->{'physical'} =  $self->getPhysical($entity->sort_order);
    }

    $self->entities($entitiesRef);
    $self->distribution($self->getDistribution());
    $self->geographicCoverage($self->getGeographicCoverage($entityId=0));
    $self->intellectualRights($self->getIntellectualRights());
    $self->keywords($self->getKeywords());
    $self->language($self->getLanguage());
    $self->methods($self->getMethods($entityId=0, $columnId=0));
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
    $dataset{'access'} = $self->access->access;
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

    my $abstract = $self->mb->searchAbstract($self->datasetId);

    return $abstract;
}

sub getAccess{
    my $self = shift;
    my $entityId = shift;

    return $self->mb->searchAccess($self->datasetId, $entityId);
}

sub getAlternateIdentifier {
    my $self = shift;
    my $entityId = shift;

    return $self->mb->searchAlternateIdentifier($self->datasetId, $entityId);
}

sub getAttributeList {
    my $self = shift;
    my $entityId = shift;
    my $attribute;
    my $attributeListRef;

    $attributeListRef = $self->mb->searchAttributeList($self->datasetId, $entityId);

    # Check each numeric type attribute and ensure that a unit value was specified,
    # e.g. a 'Temperature' attribute may have a numbertype 'real' with unit type 'celsius'.
    foreach $attribute (@$attributeListRef) {
        if ($attribute->numbertype) {
            if (not $attribute->unit) {
                warn ("No unit value specified for attribute: " . $attribute->attributeid . ", number type: " . $attribute->numberType . "\n");
            }
        }

        # Check each attribute to see if it has a taxomicCoverage element, and if so, append it to that attribute.
        my $taxonomicCoverageRef = $self->mb->searchTaxonomicCoverage($self->datasetId, $entityId, $attribute->column_sort_order);
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

        $attribute->{'methods'} = $self->mb->searchMethods($self->datasetId, $entityId, $attribute->column_sort_order);
    }

    #return $self->mb->searchAttributeList($self->datasetId, $entityId);
    return $attributeListRef;
}

sub getAssociatedParties{
    my $self = shift;

    return $self->mb->searchAssociatedParties($self->datasetId);
}

sub getContacts{
    my $self = shift;

    return $self->mb->searchContacts($self->datasetId);
}

sub getCreators{
    my $self = shift;

    return $self->mb->searchCreators($self->datasetId);
}


sub getGeographicCoverage{
    my $self = shift;
    my $entityId = shift;

    return $self->mb->searchGeographicCoverage($self->datasetId, $entityId);
}

sub getDistribution {
    my $self = shift;

    my $distribution = $self->mb->searchDistribution($self->datasetId);

    return $distribution;
}

sub getEntities{
    my $self = shift;

    return $self->mb->searchEntities($self->datasetId);
}

sub getIntellectualRights {
    my $self = shift;

    my $intellectualRights = $self->mb->searchIntellectualRights ($self->datasetId);

    return $intellectualRights;
}

sub getKeywords{
    my $self = shift;

    return $self->mb->searchKeywords($self->datasetId);
}

sub getLanguage{
    my $self = shift;

    my $language = $self->mb->searchLanguage($self->datasetId);

    return $language;
}

sub getMethods {
    my $self = shift;
    my $entityId = shift;
    my $columnId = shift;

    #my $method;
    #my @methods;

    #@methods = $self->mb->searchMethods($self->datasetId, $entityId);

    #for $method (@methods) {
    #    print "getMethods method: " . $method->methodstep . "\n";
    #}

    return $self->mb->searchMethods($self->datasetId, $entityId, $columnId);
}

sub getPhysical{
    my $self = shift;
    my $entityId = shift;

    my $language = $self->mb->searchPhysical($self->datasetId, $entityId);

    return $language;
}

sub getProject {
    my $self = shift;

    my $project = $self->mb->searchProject($self->datasetId);

    return $project;
}

sub getPublisher {
    my $self = shift;

    my $publisher = $self->mb->searchPublisher($self->datasetId);

    return $publisher;
}

sub getTaxonomicCoverage{
    my $self = shift;
    my $entityId = shift;
    my $columnId = shift;

    return $self->mb->searchTaxonomicCoverage($self->datasetId, $entityId, $columnId);
}

sub getTemporalCoverage{
    my $self = shift;
    my $entityId = shift;
    my $columnId = shift;

    return $self->mb->searchTemporalCoverage($self->datasetId, $entityId, $columnId);
}

sub getTitle{
    my $self = shift;

    return $self->mb->searchTitle($self->datasetId);
}

sub getUnitList {
    my $self = shift;

    return $self->mb->searchUnitList($self->datasetId);
}

sub writeXML {

    use Template;

    my ($self, %args) = @_;
    my $validate     = $args{validate};
    my $runEMLParser = $args{runEMLParser};
    my $verbose      = $args{verbose};

    my $EMLlocation;
    my $EML_XSD;
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

    print STDERR "------------------------------------------------------------------------------------------------------------------------\n";
    print STDERR "Command line: " . $0 . " " . join(' ', @ARGV) . "\n";
    print STDERR "Database name: " . $self->databaseName . "\n";
    print STDERR "Dataset Id: " . $self->datasetId . "\n\n";
    # Create an XML object from the string returned from the template engine. This
    # call will check for well-formedness.
    print STDERR "Creating EML document.\n", if $verbose;

    eval {
        $doc = XML::LibXML->load_xml(string => $output, { no_blanks => 1 });
    };

    if ($@) {
        print STDERR $self->datasetId . " : Error creating XML document: $@\n";
        die $self->datasetId . ": Processing halted because the generated XML document is not valid.\n";
    } 

    # IF we are going to validate or EMLParse, read in the EML XML Schema.
    if ($validate || $runEMLParser) {
        # Load config file
        my $cfg = new Config::Simple('config/mb2eml.ini');
        $EMLlocation = $cfg->param('EMLlocation');

        if (! defined $EMLlocation) {
            print STDERR "The location of the EML distribution is not defined. Please enter the parameter \"EMLlocation\" into the config/mb2eml.ini file.\n";
        } 

        $EML_XSD = $EMLlocation . "/eml.xsd";
        eval {
            $xmlschema = XML::LibXML::Schema->new( location => $EML_XSD);
        };

        if ($@) {
            print STDERR $self->datasetId . ": Unable to initialize XML Schema: $@\n";
        } 
    }

    # Validate the EML document against the EML XML Schema
    if ($validate) {
        if (! defined $EMLlocation) {
            print STDERR "Unable to perform validation with eml.xsd because the location of the EML distribution is unknown.\n";
        } else {
            print STDERR "Running XML Schema validation.\n", if $verbose;
            eval {
                $xmlschema = XML::LibXML::Schema->new( location => $EML_XSD);
                $valid = $xmlschema->validate( $doc );
            };
            if ($@) {
                print STDERR $self->datasetId . ": Error validating XML document: $@\n";
            } 
        }
    }

    # Run the EMLParser against the newly created document to check that all references are correct.
    if ($runEMLParser) {
        # Check if the EMLlocation parameter is a WEB URL. The EMLParser can't be run with a WEB URL as Java
        # can't be invoked remotely (unless Java RMI is implemented, which it is not for EMLParser).
        if ($EMLlocation =~ /^http:/) {
            warn 'The config parameter "EMLlocation" is a web URL. EMLlocation must be a local directory to run EMLParser.'
        } else {
            print STDERR "Running EMLParser.\n", if $verbose;
            if (! defined $EMLlocation) {
                print STDERR "Unable to run EML Parser because the location of the EML distribution is unknown.";
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
                } else {
                    print STDERR "$result\n", if $verbose;
                }
            }
        }
    }

    return $doc->toString(1);
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

EML - construct an EML object and write out an EML document as XML

=head1 SYNOPSIS

    my $eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );

=head1 DESCRIPTION

The MB2EML package reads data from the PostgreSQL Metabase database using B<MB2EML::Metabase> and writes out and Ecological Metadata
Language documents. 

The Metabase 
database schema was developed at the Georgia Costal Ecosystems LTER I<https://gce-lter.marsci.uga.edu/public/app/resources.asp?type=document&category=informatics&theme=Database%20schemas>

=head2 Database schema

MB2EML uses a I<static> database schema when querying Metabase. This on-disk representation of the schema is created by the I<saveSchema.pl> script, which uses the DBIx module.

=head1 METHODS

=head2 new

=over 4

=item Arguments: $databaseName, $datasetId

=item Return Value: an MB2EML::EML object

=back

$eml = MB2EML::EML->new( { databaseName => $databaseName, datasetId => $datasetId } );

This object constructor takes two arguments, I<$databaseName> and I<$datasetId>. The argument I<$databaseName> is the name of the 
PostgreSQL database containing the Metabase schema, and I<$datasetId> is the dataset identifier number of the dataset to query.

=head2 writeXML

=over 4

=item Arguments: $validate, $runEMLParser, $verbose

=item Return Value: No return value

=back

$output = $eml->writeXML(validate => $validate, runEMLParser => $runEMLParser, verbose => $verbose);

Once the EML object is created, you can write it out to an XML document that conforms to the EML XML Schema.
If the argument I<$validate> is true (i.e. '1'), then the EML document is validated using the EML XML Schema
specified in the ./config/mb2eml.ini file. If I<$runEMLParser> is true, then the KNB I<runEMLParser> program
will be run to perform further validation checks on the EML document. If I<$verbose> is true, then verbose
information will be printed to stdout.

=head1 AUTHOR

Peter Slaughter "<pslaughter@msi.ucsb.edu>"

=cut


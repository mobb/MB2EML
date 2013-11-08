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
has 'databaseName'       => ( is => 'rw', isa => 'Str', required => 1 );
has 'dataset'            => ( is => 'rw', isa => 'HashRef');
has 'datasetId'          => ( is => 'rw', isa => 'Num' , required => 1);
has 'mb'                 => ( is => 'rw', isa => 'Object');
has 'unitList'           => ( is => 'rw', isa => 'ArrayRef' );

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
    my $shortName;
    my $title;

    $self->mb(MB2EML::Metabase->new({ databaseName => $self->databaseName}));

    # Initialize attributes, in case they will be used by the methods.
    $self->unitList($self->getUnitList());

    # Construct a 'dataset' hash that contains all info we are using in eml-dataset. This
    # is done for ease of use so that methods such as 'writeXML' don't have to know
    # the structure of the eml-dataset module (as all the structure is built here).
    my %dataset = ();
    $dataset{'abstract'} = $self->getAbstract();

    $dataset{'access'} = $self->getAccess($entityId=0);
    my $alternateId = $self->getAlternateIdentifier($entity=0);
    $dataset{'alternateidentifier'} = $alternateId->alternateidentifier;
    $dataset{'associatedParties'} = $self->getAssociatedParties();
    $dataset{'contacts'} = $self->getContacts();
    $dataset{'coverage'} = ( { 'geographiccoverage'  => $self->getGeographicCoverage($entityId=0, $columnId=0),
                               'taxonomiccoverage'   => $self->getTaxonomicCoverage($entityId=0, 0),
                               'temporalcoverage'    => $self->getTemporalCoverage($entityId=0, 0)} );
    $dataset{'creators'} = $self->getCreators();
    $dataset{'distribution'} = $self->getDistribution();
    $dataset{'entities'} = $self->getEntities();
    $dataset{'id'} = $self->datasetId;
    $dataset{'intellectualRights'} = $self->getIntellectualRights();
    $dataset{'keywords'} = $self->getKeywords();
    $dataset{'language'} = $self->getLanguage();
    $dataset{'methods'} = $self->getMethods($entityId=0, $columnId=0);
    my $packageId = $self->getPackageId();
    if (defined $packageId) {
        $dataset{'packageId'} = $packageId->packageid;
    } else {
        print STDERR "Warning: content not found in Metabase for packageId\n";
        $dataset{'packageId'} = "";
    }

    my $pDate = $self->getPubDate();
    $dataset{'pubdate'} = $pDate->pubdate;
    $dataset{'project'} = $self->getProject();
    $dataset{'publisher'} = $self->getPublisher();

    $shortName = $self->getShortName();
    if (defined $shortName) {
        $dataset{'shortname'} = $shortName->shortname;
    } else {
        $dataset{'shortname'} = "";
        print STDERR "Warning: content not found in Metabase for <shortName>\n";
    }

    $title = $self->getTitle();
    if (defined $title) {
        $dataset{'title'} = $title->title;
    } else {
        print STDERR "Warning: content not found in Metabase for <title>\n";
    }

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

    # Loop through the list of attributes to perform validity checks and to add attribute
    # level elements.
    foreach $attribute (@$attributeListRef) {
        # Check each numeric type attribute and ensure that a unit value was specified,
        # e.g. a 'Temperature' attribute may have a numbertype 'real' with unit type 'celsius'.
        if ($attribute->numbertype) {
            if (not $attribute->unit) {
                warn ("No unit value specified for attribute: " . $attribute->attributeid . ", number type: " . $attribute->numberType . "\n");
            }
        }

        # Check each attribute to see if it has a taxomicCoverage element, and if so, append it to that attribute.
        $attribute->{'coverage'}->{'taxonomiccoverage'} = $self->getTaxonomicCoverage($entityId, $attribute->column_position);

        # If a geographic coverage for this attribute is found, add it to the attribute hash
        $attribute->{'coverage'}->{'geographiccoverage'} = $self->getGeographicCoverage($entityId, $attribute->column_position); 
        # If a temporal coverage for this attribute is found, add it to the attribute hash
        $attribute->{'coverage'}->{'temporalcoverage'} = $self->getTemporalCoverage($entityId, $attribute->column_position);

        $attribute->{'methods'} = $self->getMethods($entityId, $attribute->column_position);
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
    my $columnId= shift;

    return $self->mb->searchGeographicCoverage($self->datasetId, $entityId, $columnId);
}

sub getDistribution {
    my $self = shift;

    my $distribution = $self->mb->searchDistribution($self->datasetId);

    return $distribution;
}

sub getEntities{
    my $self = shift;

    my $columnId;
    my $entitiesRef = $self->mb->searchEntities($self->datasetId);
    my $entity;

    for $entity (@$entitiesRef) {
        $entity->{'access'} = $self->getAccess($entity->entity_position);
        # Uncomment this line when the vw_eml_alternateidentifier view is implemented for entities
        #my $alternateId = $self->getAlternateIdentifier($entity->entity_position);
        #$entity->{'alternateidentifier'} = $alternateId->alternateidentifier;
        $entity->{'attributeList'} = $self->getAttributeList($entity->entity_position);
        $entity->{'coverage'}->{'geographiccoverage'} = $self->getGeographicCoverage($entity->entity_position, $columnId=0);
        $entity->{'methods'} = $self->getMethods($entity->entity_position, $columnId=0);
        $entity->{'coverage'}->{'temporalcoverage'} = $self->getTemporalCoverage($entity->entity_position, $columnId=0);
        $entity->{'coverage'}->{'taxonomiccoverage'} = $self->getTaxonomicCoverage($entity->entity_position, $columnId=0);
        $entity->{'physical'} =  $self->getPhysical($entity->entity_position);
    }

    return $entitiesRef;

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

    return $self->mb->searchMethods($self->datasetId, $entityId, $columnId);
}

sub getPackageId {
    my $self = shift;

    return $self->mb->searchPackageId($self->datasetId);
}

sub getPhysical{
    my $self = shift;
    my $entityId = shift;

    return $self->mb->searchPhysical($self->datasetId, $entityId);

}

sub getProject {
    my $self = shift;

    return $self->mb->searchProject($self->datasetId);
}

sub getPublisher {
    my $self = shift;

    return $self->mb->searchPublisher($self->datasetId);
}

sub getPubDate {
    my $self = shift;

    return $self->mb->searchPubDate($self->datasetId);
}

sub getShortName {
    my $self = shift;

    return $self->mb->searchShortName($self->datasetId);
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
    my $configFilename = "./config/mb2eml.ini";
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
    #$templateVars{'packageId'} = $self->packageId;
    $templateVars{'dataset'} = $self->dataset;
    $templateVars{'additionalMetadata'}{'unitList'} = $self->unitList;

    # Fill in the template, sending template output to a text string
    $tt->process($templateName, \%templateVars, \$output )
        || die $tt->error;

    my $optStr = "";
    $optStr .= "p", if ($validate);
    $optStr .= "v", if ($verbose);
    $optStr .= "x", if ($runEMLParser);
    $optStr  = "-" . $optStr, if ($optStr ne "");

    print STDERR "------------------------------------------------------------------------------------------------------------------------\n";
    print STDERR "Command line: " . $0 . " " . $optStr . " " . join(' ', @ARGV) . "\n";
    print STDERR "DatabaseName: " . $self->databaseName . "\n";
    print STDERR "DatasetId: " . $self->datasetId . "\n\n";
    # Create an XML object from the string returned from the template engine. This
    # call will check for well-formedness.
    print STDERR "Creating EML document.\n", if $verbose;

    eval {
        $doc = XML::LibXML->load_xml(string => $output, { no_blanks => 1 });
    };

    if ($@) {
        print STDERR $self->datasetId . " : Error creating XML document: $@\n";
        print STDERR "The following is the invalid raw XML: \n";
        print STDERR $output . "\n";
        die $self->datasetId . ": Processing halted because the generated XML document is not valid.\n";
    } 

    # IF we are going to validate or EMLParse, read in the EML XML Schema.
    if ($validate || $runEMLParser) {
        # Load config file
        my $cfg = new Config::Simple('config/mb2eml.ini');

        if (not defined $cfg) {
            die "Error: configuration file \"$configFilename\" not found.";
        }

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

    #my $subDoc = XML::LibXML::Document->createDocument();

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


package MB2EML::Metabase;
use Moose;
use strict;
use warnings;
use Config::Simple;

use lib './lib';
#use namespace::autoclean;

has 'schema' => ( is => 'rw' );
has 'databaseName' => ( is => 'ro', isa => 'Str', required => 1);
has 'datasetid' => ( is => 'ro', isa => 'Num');

# Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing
sub BUILD {
    my $self = shift;

    my $configFilename = "./config/mb2eml.ini";

    # Load config file
    my $cfg = new Config::Simple($configFilename);

    if (not defined $cfg) {
        die "Error: configuration file \"$configFilename\" not found.";
    }

    # search PostgreSQL account and pass
    my $account = $cfg->param('account');
    my $pass = $cfg->param('pass');
    my $host = $cfg->param('host');
    my $port = $cfg->param('port');

    # Open a conection to the mcr_metabase database. The 'quote_names' option causes table
    # names and columns to be quoted in any SQL that DBIC creates. This is necessary if the
    # Postgresql table names or field names are mixed case, because if Postgresql is sent a
    # query with mixed case names, it will 'case_fold' them to lower case, so the names in the
    # SQL won't match the Postgresql names and the query will fail.
    # Note: export DBIC_TRACE=1 in the parent Unix shell to have DBIC print out the SQL that it generates

    # The database to use is specified at runtime, but it is necessary to import the Perl module
    # that contains the on-disk database schema. Because this must be done at runtime, the
    # 'require' statement is used instead of 'use'.
    my $schema = $self->databaseName . "::Schema";
    eval "require $schema";
    $schema->import();
    my $dbi = 'dbi:Pg:dbname=' . $self->databaseName . ';host='. $host . ';port=' . $port;
    $self->schema($schema->connect($dbi, $account, $pass,
        { on_connect_do => ['SET search_path TO mb2eml, public']}, { quote_names => 1 }));
}

sub DEMOLISH {
    my $self = shift;

    # Close any open database connection
    # Note: DEMOLISH is called automatically when this Moose object goes out of scope, which 
    # is the case at the end of the program
    $self->schema->storage->disconnect();
}

sub searchAbstract {
    my $self = shift;
    my $datasetId = shift;

    # Return a single DBIx::Class::Row
    return $self->schema->resultset('VwEmlAbstract')->search({ datasetid => $datasetId})->single;

}

sub searchAccess {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;
    my @accesses = ();

    # Return a singgle DBIx::Class::Row
    return $self->schema->resultset('VwEmlAccess')->search({ datasetid => $datasetId, entity_position => $entityPostion })->single;
}

sub searchAlternateIdentifier {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;

    # Return a single DBIx::Class::Row
    return $self->schema->resultset('VwEmlAlternateidentifier')->search({ datasetid => $datasetId })->single;
}

sub searchAssociatedParties {
    my $self = shift;
    my $datasetId = shift;
    my @associatedParties = ();

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlAssociatedparty')->search({ datasetid => $datasetId }, { order_by => { -asc => 'authorshiporder' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $associatedParty = $rs->next) {
        push(@associatedParties, $associatedParty);
        #print "party: " . $associatedParty->nameid . "\n";
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@associatedParties;
}

sub searchAttributeList {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;
    my @attributeList = ();
    my $dataType;

    # resultset returns an iterator
    # Retrieve attributes for a particular dataset and entity, ordered by entity sort order
    my $rs = $self->schema->resultset('VwEmlAttributelist')->search({ datasetid => $datasetId, entity_position => $entityPostion }, { order_by => { -asc => 'column_position' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a DBIx ResultRow object that used the column names as the accesors.
    while (my $attribute = $rs->next) {
        push(@attributeList, $attribute);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@attributeList;
}

sub searchContacts {
    my $self = shift;
    my $datasetId = shift;
    my @contacts = ();

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlContact')->search({ datasetid => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $contact = $rs->next) {
        push(@contacts, $contact);
    }

    return \@contacts;
}

sub searchCreators {
    my $self = shift;
    my $datasetId = shift;
    my @creators = ();

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlCreator')->search({ datasetid => $datasetId }, { order_by => { -asc => 'authorshiporder' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $creator = $rs->next) {
        push(@creators, $creator);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@creators;
}

sub searchDatasetIds{
    my $self = shift;
    my @ids = ();

    # Every dataset must have a title, so retrieve the ids from the title view.
    my $rs = $self->schema->resultset('VwEmlTitle')->search({}, { order_by => { -asc => 'datasetid'}} );
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $id = $rs->next) {
        push(@ids, $id->datasetid);
    }

    return \@ids;
}

sub searchDistribution {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlDistribution')->search({ datasetid => $datasetId})->single;
}

sub searchEntities{
    my $self = shift;
    my $datasetId = shift;
    my @entities;

    # resultset returns an iterator
    my $rs = $self->schema->resultset('VwEmlEntity')->search({ datasetid => $datasetId }, { order_by => { -asc => 'entity_position' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $entity = $rs->next) {
        push(@entities, $entity);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return \@entities;
}

sub searchGeographicCoverage {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;
    my $attributePosition = shift;
    my @geographicCoverage = ();

    my $rs = $self->schema->resultset('VwEmlGeographiccoverage')->search({ datasetid => $datasetId, entity_position => $entityPostion, attribute_position => $attributePosition }, 
                                                                         { order_by => { -asc => [qw/entity_position attribute_position geocoverage_sort_order/] }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $coverage = $rs->next) {
        #print "coverage: " . $coverage->begindate . "\n";
        push(@geographicCoverage, $coverage);
    }

    return \@geographicCoverage;
}

sub searchIntellectualRights {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlIntellectualrights')->search({ datasetid => $datasetId})->single;
}

sub searchKeywords {
    my $self = shift;
    my $datasetId = shift;
    my @keywords = ();

    my $rs = $self->schema->resultset('VwEmlKeyword')->search({ datasetid => $datasetId }, { order_by => { -asc => [qw/thesaurus_sort_order /]}} );
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $keyword = $rs->next) {
        push(@keywords, $keyword);
    }

    return \@keywords;
}

sub searchLanguage {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlLanguage')->search({ datasetid => $datasetId})->single;
}

sub searchMethods {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;
    my $attributePosition = shift;
    my @methods;

    my $rs = $self->schema->resultset('VwEmlMethods')->search({ datasetid => $datasetId, entity_position => $entityPostion, column_position => $attributePosition }, 
                                                              { order_by => { -asc => [qw/entity_position column_position/] }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultse
    # Each row is a hash that used the column names as the keys.
    while (my $method = $rs->next) {
        #print "metabase methodstep: " . $method->methodstep. "\n";
        push(@methods, $method);
    }

    return \@methods;
}

sub searchPackageId {
    my $self = shift;
    my $datasetId = shift;

    # Retrieve package identifier for a particular dataset
    return $self->schema->resultset('VwEmlPackageid')->search({ datasetid => $datasetId })->single;
}

sub searchPhysical {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;
    my @physical = ();

    # resultset returns resultSet object
    # Retrieve physical format description for a particular dataset and entity
    my $rs = $self->schema->resultset('VwEmlPhysical')->search({ datasetid => $datasetId, entity_position => $entityPostion });

    while (my $p = $rs->next) {
        push(@physical, $p);
    }

    return \@physical;
}

sub searchProject {
    my $self = shift;
    my $datasetId = shift;

    # Retrieve project description for a particular dataset and entity
    return $self->schema->resultset('VwEmlProject')->search({ datasetid => $datasetId })->single;
}

sub searchPubDate {
    my $self = shift;
    my $datasetId = shift;

    # Return a single DBIx::Class:Row
    return $self->schema->resultset('VwEmlPubdate')->search({ datasetid => $datasetId})->single;
}

sub searchPublisher {
    my $self = shift;
    my $datasetId = shift;

    return $self->schema->resultset('VwEmlPublisher')->search({ datasetid => $datasetId })->single;
}

sub searchShortName {
    my $self = shift;
    my $datasetId = shift;

    # Return a single DBIx::Class::Row
    return $self->schema->resultset('VwEmlShortname')->search({ datasetid => $datasetId })->single;
}

sub searchTemporalCoverage {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;
    my $attributePosition = shift;
    my @temporalCoverage = ();

    #print "$entityPostion , $datasetId \n";
    my $rs = $self->schema->resultset('VwEmlTemporalcoverage')->search({ datasetid => $datasetId, entity_position => $entityPostion, attribute_position => $attributePosition }, 
                                                                       { order_by => { -asc => [qw/entity_position attribute_position temporalcoverage_sort_order/] }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $coverage = $rs->next) {
        #print "coverage: " . $coverage->begindate . "\n";
        push(@temporalCoverage, $coverage);
    }

    return \@temporalCoverage;
}

sub searchTaxonomicCoverage {
    my $self = shift;
    my $datasetId = shift;
    my $entityPostion = shift;
    my $attributePosition = shift;
    my @taxonomicCoverage = ();

    #print "$entityPostion , $datasetId \n";
    my $rs = $self->schema->resultset('VwEmlTaxonomiccoverage')->search({ datasetid => $datasetId, entity_position => $entityPostion, attribute_position => $attributePosition }, 
                                                                        { order_by => { -asc => [qw /entity_position attribute_position/] }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $coverage = $rs->next) {
        #print "coverage: " . $coverage->begindate . "\n";
        push(@taxonomicCoverage, $coverage);
    }

    return \@taxonomicCoverage;
}

sub searchTitle{
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlTitle')->search({ datasetid => $datasetId })->single;
}

sub searchUnitList {
    my $self = shift;
    my $datasetId = shift;
    my @unitList = ();

    my $rs = $self->schema->resultset('VwStmmlUnitlist')->search({ datasetid => $datasetId }, { order_by => { -asc => 'unit'}} );
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $unit = $rs->next) {
        push(@unitList, $unit);
    }

    return \@unitList;
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Metabase.pm - retrieve data from the Metabase database.

=head1 SYNOPSIS

    $metabase = MB2EML::Metabase->new({ databaseName => $self->databaseName});

=head1 DESCRIPTION

B<Metabase.pm> uses the DBIx package to query the Metabase database, providing an abstraction layer to the database
so that higher level modules (e.g. EML.pm) don't require any details about the database, except for the name of the database
and datasetId to query.

B<Metabase.pm> is used internally by MB2EML.

=head2 Database schema

Metabase uses a static database schema when querying Metabase. This on-disk representation of the schema is created by the I<saveSchema.pl> script, which uses the 
DBIx::Class::Schema::Loader module.

=head1 METHODS

=head2 searchAbstract 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchAccess 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchAlternateIdentifier 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchAssociatedParties 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchAttributeList 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchContacts 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchCreators 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchDistribution 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchEntities

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchGeographicCoverage 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchIntellectualRights 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchKeywords 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchLanguage 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchMethods 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchPhysical 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchPackageId

=over 4

=item Arguments: $datasetId

=item Return Value: DBIx::Class::Row

=back

=head2 searchProject 

=over 4

=item Arguments: $datasetId

=item Return Value: DBIx::Class::Row

=back

=head2 searchPublisher 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchTemporalCoverage 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchTaxonomicCoverage 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head2 searchTitle

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: DBIx::Class::Row

=back

=head2 searchUnitList 

=over 4

=item Arguments: $datasetId, $entityPostion

=item Return Value: array reference to array of DBIx::Class::Row

=back

=head1 AUTHOR

Peter Slaughter "<pslaughter@msi.ucsb.edu>"

=cut


package MB2EML::Metabase;
use Moose;
use Config::Simple;

use lib '/Users/peter/Projects/MSI/LTER/MB2EML/lib';
#use namespace::autoclean;

has 'schema' => ( is => 'rw' );
has 'databaseName' => ( is => 'ro', isa => 'Str', required => 1);
has 'datasetid' => ( is => 'ro', isa => 'Num' );

# Can't override new() with Moose, so use 'BUILD' which is like a new() postprocessing
sub BUILD {
    my $self = shift;

    # Load config file
    my $cfg = new Config::Simple('config/mb2eml.ini');
    # get PostgreSQL account and pass
    my $account = $cfg->param('account');
    my $pass = $cfg->param('pass');
    my $host = $cfg->param('host');

    if ($self->databaseName eq "mcr_metabase") {
        use mcr_metabase::Schema;
        $self->schema(mcr_metabase::Schema->connect('dbi:Pg:dbname="mcr_metabase";host=' . $host, $account, $pass, 
          { on_connect_do => ['SET search_path TO mb2eml, public']}));
    }
    else {
        use sbc_metabase::Schema;
        $self->schema(sbc_metabase::Schema->connect('dbi:Pg:dbname="sbc_metabase";host='. $host, $account, $pass, 
          { on_connect_do => ['SET search_path TO mb2eml, public']}));
    }
}

sub DEMOLISH {
    my $self = shift;

    # Close any open database connection
    # Note: DEMOLISH is called automatically when this Moose object goes out of scope, which 
    # is the case at the end of the program
    $self->schema->storage->disconnect();
}

sub getAbstract {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlAbstract')->find({ datasetid => $datasetId});

}

sub getAccess {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my @accesses = ();

    # resultset returns an interator
    return $self->schema->resultset('VwEmlAccess')->find({ datasetid => $datasetId, entity_sort_order => $entityId });
    
    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
    #return @accesses;
}

sub getAssociatedParties {
    my $self = shift;
    my $datasetId = shift;
    my @associatedParties = ();

    # resultset returns an interator
    my $rs = $self->schema->resultset('VwEmlAssociatedparty')->search({ datasetid => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $associatedParty = $rs->next) {
        push(@associatedParties, $associatedParty);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return @associatedParties;
}

sub getAttributeList {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;
    my @attributeList = ();

    # resultset returns an interator
    # Retrieve attributes for a particular dataset and entity, ordered by entity sort order
    my $rs = $self->schema->resultset('VwEmlAttributelist')->search({ datasetid => $datasetId, entity_sort_order => $entityId }, { order_by => { -asc => 'column_sort_order' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $attribute = $rs->next) {
        push(@attributeList, $attribute);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return @attributeList;
}

sub getContacts {
    my $self = shift;
    my $datasetId = shift;
    my @contacts = ();

    # resultset returns an interator
    my $rs = $self->schema->resultset('VwEmlContact')->search({ datasetid => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $contact = $rs->next) {
        push(@contacts, $contact);
    }

    return @contacts;
}

sub getCreators {
    my $self = shift;
    my $datasetId = shift;
    my @creators = ();

    # resultset returns an interator
    my $rs = $self->schema->resultset('VwEmlCreator')->search({ datasetid => $datasetId }, { order_by => { -asc => 'authorshiporder' }});
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $creator = $rs->next) {
        push(@creators, $creator);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return @creators;
}

sub getDistribution {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlDistribution')->find({ datasetid => $datasetId});
}

sub getEntities{
    my $self = shift;
    my $datasetId = shift;
    my @entities = ();

    # resultset returns an interator
    my $rs = $self->schema->resultset('VwEmlEntity')->search({ datasetid => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    # Each row is a hash that used the column names as the keys.
    while (my $entity = $rs->next) {
        push(@entities, $entity);
    }

    # Put QC checking here
    # i.e. nulls for specific fields - Gastil want's a one liner
 
    return @entities;
    
}

sub getIntellectualRights {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlIntellectualrights')->find({ datasetid => $datasetId});
}

sub getKeywords {
    my $self = shift;
    my $datasetId = shift;
    my @keywords = ();

    my $rs = $self->schema->resultset('VwEmlKeyword')->search({ datasetid => $datasetId }, { order_by => { -asc => 'keywordthesaurus'}} );
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $keyword = $rs->next) {
        push(@keywords, $keyword);
    }

    return @keywords;
}

sub getLanguage {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlLanguage')->find({ datasetid => $datasetId});
}

sub getPhysical {
    my $self = shift;
    my $datasetId = shift;
    my $entityId = shift;

    # resultset returns resultSet object
    # Retrieve physical format description for a particular dataset and entity
    my $rs = $self->schema->resultset('VwEmlPhysical')->find({ datasetid => $datasetId, sort_order => $entityId });
    
    return $rs;
}

sub getProject {
    my $self = shift;
    my $datasetId = shift;

    # Retrieve project description for a particular dataset and entity
    my $rs = $self->schema->resultset('VwEmlProject')->find({ datasetid => $datasetId });
    
    return $rs;
}

sub getPublisher {
    my $self = shift;
    my $datasetId = shift;

    my $rs = $self->schema->resultset('VwEmlPublisher')->find({ datasetid => $datasetId });
    
    return $rs;
}

sub getTitle{
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlTitle')->find({ datasetid => $datasetId});
}

sub getUnitList {
    my $self = shift;
    my $datasetId = shift;
    my @unitList = ();

    my $rs = $self->schema->resultset('VwStmmlUnitlist')->search({ datasetid => $datasetId }, { order_by => { -asc => 'unit'}} );
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $unit = $rs->next) {
        push(@unitList, $unit);
    }

    return @unitList;
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

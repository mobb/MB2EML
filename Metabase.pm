#!/usr/bin/env perl

package Metabase;
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
    my $cfg = new Config::Simple('mb2eml.ini');
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

sub getAbstract {
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlAbstract')->find({ dataSetId => $datasetId});
}

sub getAttributeList {
    my $self = shift;
    my $datasetId = shift;
    my @attributeList = ();

    # resultset returns an interator
    my $rs = $self->schema->resultset('VwEmlAttributelist')->search({ dataSetId => $datasetId });
    
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
sub getCreators {
    my $self = shift;
    my $datasetId = shift;
    my @creators = ();

    # resultset returns an interator
    my $rs = $self->schema->resultset('VwEmlCreator')->search({ dataSetId => $datasetId });
    
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

sub getDatasetTitle{
    my $self = shift;
    my $datasetId = shift;

    # Return a single row, which is a hash
    return $self->schema->resultset('VwEmlTitle')->find({ dataSetId => $datasetId});
    
}

sub getEntities{
    my $self = shift;
    my $datasetId = shift;
    my @entities = ();

    # resultset returns an interator
    my $rs = $self->schema->resultset('VwEmlEntity')->search({ dataSetId => $datasetId });
    
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

sub getKeywords {
    my $self = shift;
    my $datasetId = shift;
    my @keywords = ();

    my $rs = $self->schema->resultset('VwEmlKeyword')->search({ dataSetId => $datasetId });
    
    # Repackage the resultset as an array of rows, which is a more standard representaion,
    # i.e. the user doesn't have to know how to use a DBIx resultset
    while (my $keyword = $rs->next) {
        push(@keywords, $keyword);
    }

    return @keywords;
}

# Make this Moose class immutable
__PACKAGE__->meta->make_immutable;

1;

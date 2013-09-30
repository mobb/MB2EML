use utf8;
package sbc_metabase::Schema::Result::VwEmlAttributelist;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlAttributelist

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_attributelist>

=cut

__PACKAGE__->table("vw_eml_attributelist");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 entity_position

  data_type: 'integer'
  is_nullable: 1

=head2 column_position

  data_type: 'smallint'
  is_nullable: 1

=head2 attribute_id

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 attributename

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 attributelabel

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 attributedefinition

  data_type: 'varchar'
  is_nullable: 1
  size: 2000

=head2 storagetype

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 measurementscale

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 nonnumericdomain

  data_type: 'text'
  is_nullable: 1

=head2 formatstring

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 precision_datetime

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 enumeration_xml

  data_type: 'xml'
  is_nullable: 1

=head2 definition_text_pattern

  data_type: 'varchar'
  is_nullable: 1
  size: 500

=head2 unit

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 precision_numeric

  data_type: 'double precision'
  is_nullable: 1

=head2 numbertype

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 bounds_xml

  data_type: 'xml'
  is_nullable: 1

=head2 missingvaluecode_xml

  data_type: 'xml'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "entity_position",
  { data_type => "integer", is_nullable => 1 },
  "column_position",
  { data_type => "smallint", is_nullable => 1 },
  "attribute_id",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "attributename",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "attributelabel",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "attributedefinition",
  { data_type => "varchar", is_nullable => 1, size => 2000 },
  "storagetype",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "measurementscale",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "nonnumericdomain",
  { data_type => "text", is_nullable => 1 },
  "formatstring",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "precision_datetime",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "enumeration_xml",
  { data_type => "xml", is_nullable => 1 },
  "definition_text_pattern",
  { data_type => "varchar", is_nullable => 1, size => 500 },
  "unit",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "precision_numeric",
  { data_type => "double precision", is_nullable => 1 },
  "numbertype",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "bounds_xml",
  { data_type => "xml", is_nullable => 1 },
  "missingvaluecode_xml",
  { data_type => "xml", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-30 13:23:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CMBfs7vg7Nf+quXrrOUNzA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

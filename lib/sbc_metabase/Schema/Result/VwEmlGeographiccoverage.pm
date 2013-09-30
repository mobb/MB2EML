use utf8;
package sbc_metabase::Schema::Result::VwEmlGeographiccoverage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlGeographiccoverage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_geographiccoverage>

=cut

__PACKAGE__->table("vw_eml_geographiccoverage");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 entity_position

  data_type: 'integer'
  is_nullable: 1

=head2 attribute_position

  data_type: 'integer'
  is_nullable: 1

=head2 geocoverage_sort_order

  data_type: 'integer'
  is_nullable: 1

=head2 id

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 geographicdescription

  data_type: 'text'
  is_nullable: 1

=head2 northboundingcoordinate

  data_type: 'double precision'
  is_nullable: 1

=head2 southboundingcoordinate

  data_type: 'double precision'
  is_nullable: 1

=head2 eastboundingcoordinate

  data_type: 'double precision'
  is_nullable: 1

=head2 westboundingcoordinate

  data_type: 'double precision'
  is_nullable: 1

=head2 gring

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 is_ref

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "entity_position",
  { data_type => "integer", is_nullable => 1 },
  "attribute_position",
  { data_type => "integer", is_nullable => 1 },
  "geocoverage_sort_order",
  { data_type => "integer", is_nullable => 1 },
  "id",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "geographicdescription",
  { data_type => "text", is_nullable => 1 },
  "northboundingcoordinate",
  { data_type => "double precision", is_nullable => 1 },
  "southboundingcoordinate",
  { data_type => "double precision", is_nullable => 1 },
  "eastboundingcoordinate",
  { data_type => "double precision", is_nullable => 1 },
  "westboundingcoordinate",
  { data_type => "double precision", is_nullable => 1 },
  "gring",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "is_ref",
  { data_type => "boolean", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-30 13:23:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/GgsvyMlsOU1/aXacTBm/w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

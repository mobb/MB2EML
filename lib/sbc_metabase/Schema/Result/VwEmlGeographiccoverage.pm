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

=head2 entity_sort_order

  data_type: 'integer'
  is_nullable: 1

=head2 column_sort_order

  data_type: 'integer'
  is_nullable: 1

=head2 id

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 geographicdescription

  data_type: 'text'
  is_nullable: 1

=head2 northboundingcoordinate

  data_type: 'real'
  is_nullable: 1

=head2 southboundingcoordinate

  data_type: 'real'
  is_nullable: 1

=head2 eastboundingcoordinate

  data_type: 'real'
  is_nullable: 1

=head2 westboundingcoordinate

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 0 },
  "entity_sort_order",
  { data_type => "integer", is_nullable => 0 },
  "column_sort_order",
  { data_type => "integer", is_nullable => 0 },
  "id",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "geographicdescription",
  { data_type => "text", is_nullable => 1 },
  "northboundingcoordinate",
  { data_type => "real", is_nullable => 1 },
  "southboundingcoordinate",
  { data_type => "real", is_nullable => 1 },
  "eastboundingcoordinate",
  { data_type => "real", is_nullable => 1 },
  "westboundingcoordinate",
  { data_type => "real", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-08-14 16:35:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SVuN1kumbqEjuL4z3kRz8g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key(qw/ datasetid entity_sort_order column_sort_order /);
1;

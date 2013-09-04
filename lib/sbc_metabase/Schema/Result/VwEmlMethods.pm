use utf8;
package sbc_metabase::Schema::Result::VwEmlMethods;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlMethods

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_methods>

=cut

__PACKAGE__->table("vw_eml_methods");

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

=head2 methodstep_sort_order

  data_type: 'smallint'
  is_nullable: 1

=head2 methodstep

  data_type: 'xml'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 0 },
  "entity_sort_order",
  { data_type => "integer", is_nullable => 0 },
  "column_sort_order",
  { data_type => "integer", is_nullable => 0 },
  "methodstep_sort_order",
  { data_type => "smallint", is_nullable => 1 },
  "methodstep",
  { data_type => "xml", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-08-14 16:35:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6x66MaTypWntY4HtkI8ZGw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key(qw/ datasetid entity_sort_order column_sort_order /);
1;

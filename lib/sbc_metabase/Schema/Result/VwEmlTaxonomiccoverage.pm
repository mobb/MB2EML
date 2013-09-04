use utf8;
package sbc_metabase::Schema::Result::VwEmlTaxonomiccoverage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlTaxonomiccoverage

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_taxonomiccoverage>

=cut

__PACKAGE__->table("vw_eml_taxonomiccoverage");

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

=head2 taxonomiccoverage_xml

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
  "taxonomiccoverage_xml",
  { data_type => "xml", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-22 14:24:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ct2o7/5FOWwI1HzYgmTeTw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key(qw/ datasetid entity_sort_order column_sort_order /);
1;

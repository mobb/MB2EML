use utf8;
package mcr_metabase::Schema::Result::VwEmlMethods;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mcr_metabase::Schema::Result::VwEmlMethods

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

=head2 entity_position

  data_type: 'integer'
  is_nullable: 1

=head2 column_position

  data_type: 'integer'
  is_nullable: 1

=head2 min

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "entity_position",
  { data_type => "integer", is_nullable => 1 },
  "column_position",
  { data_type => "integer", is_nullable => 1 },
  "min",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-03 13:48:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:53PJnw33zcL1RtuZNQ2pMQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

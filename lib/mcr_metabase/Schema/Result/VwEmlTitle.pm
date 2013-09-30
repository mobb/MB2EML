use utf8;
package mcr_metabase::Schema::Result::VwEmlTitle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mcr_metabase::Schema::Result::VwEmlTitle

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_title>

=cut

__PACKAGE__->table("vw_eml_title");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 title

  data_type: 'varchar'
  is_nullable: 1
  size: 300

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "title",
  { data_type => "varchar", is_nullable => 1, size => 300 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-30 13:21:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:l+8eTNVeO4qTr0HiBxeE6Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

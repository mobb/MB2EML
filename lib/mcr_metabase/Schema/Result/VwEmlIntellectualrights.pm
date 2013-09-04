use utf8;
package mcr_metabase::Schema::Result::VwEmlIntellectualrights;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mcr_metabase::Schema::Result::VwEmlIntellectualrights

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_intellectualrights>

=cut

__PACKAGE__->table("vw_eml_intellectualrights");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 intellectualrights

  data_type: 'xml'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "intellectualrights",
  { data_type => "xml", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-22 14:22:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LlUz3WaH6a7TwVzFvbZFtA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

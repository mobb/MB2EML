use utf8;
package sbc_metabase::Schema::Result::VwEmlShortname;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlShortname

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_shortname>

=cut

__PACKAGE__->table("vw_eml_shortname");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'text'
  is_nullable: 1

=head2 shortname

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "text", is_nullable => 1 },
  "shortname",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-30 16:48:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kd2eobPxe13A7mwj5blsAQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

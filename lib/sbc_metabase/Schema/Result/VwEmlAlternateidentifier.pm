use utf8;
package sbc_metabase::Schema::Result::VwEmlAlternateidentifier;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlAlternateidentifier

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_alternateidentifier>

=cut

__PACKAGE__->table("vw_eml_alternateidentifier");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 alternateidentifier

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "alternateidentifier",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-30 13:23:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qFNwLwHTv9IrwuEbbPUQvA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

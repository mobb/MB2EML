use utf8;
package mcr_metabase::Schema::Result::VwEmlPackageid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mcr_metabase::Schema::Result::VwEmlPackageid

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_packageid>

=cut

__PACKAGE__->table("vw_eml_packageid");

=head1 ACCESSORS

=head2 DataSetID

  accessor: 'data_set_id'
  data_type: 'text'
  is_nullable: 1

=head2 packageId

  accessor: 'package_id'
  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "DataSetID",
  { accessor => "data_set_id", data_type => "text", is_nullable => 1 },
  "packageId",
  { accessor => "package_id", data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-20 09:24:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TOkxl8OZW9cvl9RAY/wNvw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

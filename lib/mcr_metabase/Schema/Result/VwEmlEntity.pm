use utf8;
package mcr_metabase::Schema::Result::VwEmlEntity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mcr_metabase::Schema::Result::VwEmlEntity

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_entity>

=cut

__PACKAGE__->table("vw_eml_entity");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 sort_order

  data_type: 'integer'
  is_nullable: 1

=head2 entityname

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 entitytype

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 entitydescription

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 numberofrecords

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 0 },
  "sort_order",
  { data_type => "integer", is_nullable => 0 },
  "entityname",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "entitytype",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "entitydescription",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "numberofrecords",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-22 14:22:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w+y9ZdKjur3wkRoLJIwbAQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key(qw/ datasetid sort_order /);
1;

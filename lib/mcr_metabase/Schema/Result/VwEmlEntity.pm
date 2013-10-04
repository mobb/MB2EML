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

=head2 entity_position

  data_type: 'integer'
  is_nullable: 1

=head2 entity_id

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

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
  size: 1000

=head2 additionalinfo

  data_type: 'varchar'
  is_nullable: 1
  size: 7000

=head2 numberofrecords

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "entity_position",
  { data_type => "integer", is_nullable => 1 },
  "entity_id",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "entityname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "entitytype",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "entitydescription",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
  "additionalinfo",
  { data_type => "varchar", is_nullable => 1, size => 7000 },
  "numberofrecords",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-30 13:21:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:paDA33t+ZSdW9q4J2VrBAg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

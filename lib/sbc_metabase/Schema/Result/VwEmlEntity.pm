use utf8;
package sbc_metabase::Schema::Result::VwEmlEntity;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlEntity

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

=head2 numberofrecords

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "sort_order",
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
  "numberofrecords",
  { data_type => "integer", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-20 09:25:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L7yOQpGVYL5aOwCF11b3JA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

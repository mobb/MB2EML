use utf8;
package mcr_metabase::Schema::Result::VwStmmlUnitlist;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mcr_metabase::Schema::Result::VwStmmlUnitlist

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_stmml_unitlist>

=cut

__PACKAGE__->table("vw_stmml_unitlist");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 unit

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 unittype

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 abbreviation

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 multipliertosi

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 parentsi

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 constanttosi

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 1000

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 0 },
  "unit",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "unittype",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "abbreviation",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "multipliertosi",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "parentsi",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "constanttosi",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 1000 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-22 14:22:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ItSU53jb4eYzqGGUUgqZrA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key(qw/ datasetid unit /);
1;

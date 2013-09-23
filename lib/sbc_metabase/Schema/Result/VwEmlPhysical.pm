use utf8;
package sbc_metabase::Schema::Result::VwEmlPhysical;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlPhysical

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_physical>

=cut

__PACKAGE__->table("vw_eml_physical");

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

=head2 objectname

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 size

  data_type: 'text'
  is_nullable: 1

=head2 unit

  data_type: 'text'
  is_nullable: 1

=head2 characterencoding

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 numheaderlines

  data_type: 'smallint'
  is_nullable: 1

=head2 numfooterlines

  data_type: 'smallint'
  is_nullable: 1

=head2 recorddelimiter

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 attributeorientation

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 fielddelimiter

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 collapsedelimiters

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 quotecharacter

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 url

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "sort_order",
  { data_type => "integer", is_nullable => 1 },
  "entityname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "objectname",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "size",
  { data_type => "text", is_nullable => 1 },
  "unit",
  { data_type => "text", is_nullable => 1 },
  "characterencoding",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "numheaderlines",
  { data_type => "smallint", is_nullable => 1 },
  "numfooterlines",
  { data_type => "smallint", is_nullable => 1 },
  "recorddelimiter",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "attributeorientation",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "fielddelimiter",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "collapsedelimiters",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "quotecharacter",
  { data_type => "char", is_nullable => 1, size => 1 },
  "url",
  { data_type => "text", is_nullable => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-20 09:25:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+lQ4Gw6VFc5VhDphdHy2ag


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

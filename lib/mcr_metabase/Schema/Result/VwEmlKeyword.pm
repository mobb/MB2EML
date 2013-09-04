use utf8;
package mcr_metabase::Schema::Result::VwEmlKeyword;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mcr_metabase::Schema::Result::VwEmlKeyword

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_keyword>

=cut

__PACKAGE__->table("vw_eml_keyword");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 keyword

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 keywordtype

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 keywordthesaurus

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 0 },
  "keyword",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "keywordtype",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "keywordthesaurus",
  { data_type => "varchar", is_nullable => 1, size => 250 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-22 14:22:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:o/KWbP44XnXht6scbld27Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->set_primary_key(qw/ datasetid keyword /);
1;

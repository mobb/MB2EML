use utf8;
package sbc_metabase::Schema::Result::VwEmlAssociatedparty;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

sbc_metabase::Schema::Result::VwEmlAssociatedparty

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<vw_eml_associatedparty>

=cut

__PACKAGE__->table("vw_eml_associatedparty");

=head1 ACCESSORS

=head2 datasetid

  data_type: 'integer'
  is_nullable: 1

=head2 authorshiporder

  data_type: 'smallint'
  is_nullable: 1

=head2 authorshiprole

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 nameid

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 givenname

  data_type: 'text'
  is_nullable: 1

=head2 givenname2

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 surname

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 organization

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 address1

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address2

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 address3

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 state

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 country

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 zipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 phone1

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 phone2

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 fax

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 role

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=cut

__PACKAGE__->add_columns(
  "datasetid",
  { data_type => "integer", is_nullable => 1 },
  "authorshiporder",
  { data_type => "smallint", is_nullable => 1 },
  "authorshiprole",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "nameid",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "givenname",
  { data_type => "text", is_nullable => 1 },
  "givenname2",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "surname",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "organization",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "address1",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address2",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "address3",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "state",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "zipcode",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "phone1",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "phone2",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "fax",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "role",
  { data_type => "varchar", is_nullable => 1, size => 100 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-20 09:25:00
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sZq+nDbQG+mVZ0WWldgG6A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

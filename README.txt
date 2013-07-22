
Introduction

The MB2EML Perl package is used to create EML documents from the
Metabase database system developed at Georgia Coastal LTER.

Package Design

The Perl MB2EML package currently contains two modules, Metabase.pm
and EML.pm.

Metabase.pm module
----------------------

The Metabase.pm module provides a simple, high level API for querying
Metabase. Metabase.pm uses the Perl DBIx module, an Object Relational Mapper(ORM),
that defines an abstraction layer to the underlying database, providing
isolation from changes to the database, and making it unnecessary to write
SQL in Perl code.

Data is retrieved via accessor functions (e.g. getContacts) which are based
on Metabase views.

Any database related processing should happen in this module, such as checking
for NULL or invalid values.

This module is intended to be used internally by the MB2EML package and does not
need to be called directly by a client program.

Because Metabase.pm uses DBIx, a representation of the database schema must be created
and stored on disk. The program saveSchema.pl can be used to create this schema
representation.

EML.pm module
-------------

The EML.pm module provides an API that 
metabase and does

Client program
--------------

The example client program 'writeEML.pl' uses EML.pm to construct an EML document
from Metabase. The only information that writeEML.pl needs to give to EML.pm is
the database name and dataset id.

Data flow
---------

The flow of information from Metabase to the final EML document is:


     database -> Metabase.pm -> EML.pm -> client program




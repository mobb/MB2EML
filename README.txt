
Introduction

The MB2EML Perl package is used to create EML documents from the
Metabase database system developed at Georgia Coastal LTER.

Package Design

The Perl MB2EML package currently contains two modules, Metabase.pm
and EML.pm.

Metabase.pm module
----------------------

The Metabase.pm module provides a simple, high level API for querying
Metabase. Metabase.pm uses the Perl DBIx module, an Object Relational Mapper (ORM),
that defines an abstraction layer to the underlying database, providing
isolation from changes to the database, and making it unnecessary to write
SQL in Perl code.

Data is retrieved via accessor functions (e.g. seasrchContacts) which are based
on Metabase views defined in the MB2EML PostgreSQL schema.

Any database related processing should happen in this module, such as checking
for NULL or invalid values.

This module is intended to be used internally by the MB2EML package and does not
need to be called directly by a client program.

Because Metabase.pm uses DBIx, a representation of the database schema must be created
and stored on disk. This schema representation is stored on disk so that it does not
have to be recreated each time the Metabase.pm module is called. 

The program saveSchema.pl can be used to create this schema representation.

EML.pm module
-------------

The EML.pm module provides an API that is used to assemble all required metadata into
an EML structure and from this
create an XML document. Any data integrity checking should happen in this module
for example, ensuring that for a specified dataset, all the required EML data
is available.

This module uses the Perl Templating Toolkit in order to render the EML data
to XML.

After the XML document is created, it is verified using the eml.xsd XML Schema
that is contained in the EML 2.1.1 distribution available at
http://knb.ecoinformatics.org/software/eml/

Client program
--------------

The example client program 'writeEML.pl' uses EML.pm to construct an EML document
from Metabase. The only information that writeEML.pl needs to give to EML.pm is
the database name and dataset id.

Data flow
---------

The flow of information from Metabase to the final EML document is:

     database -> Metabase.pm -> EML.pm -> client program

Installing MB2EML
-----------------

The following directions describe how to install the development release of 
MB2EML, as development software has not been merged into the main branch
yet.

1. Get the latest source code release from Github:

   git clone https://github.com/sbpcs/MB2EML.git MB2EML

2. Switch to the 'devel' branch as it is the most current.

   % cd MB2EML
   % git checkout devel

3. Create and edit the configuration file that contains authorization 
   information necessary to connect to your database:

   % cp config/mb2eml.ini.sample config/mb2eml.ini
   % vi config/mb2eml.ini

4. Install the required Perl modules:

     Moose
     Template
     Config::Simple
     DBIx
     XML::LibXML

5. Edit MB2EML/*.pm, writeEML.pl and change "usr lib /User/peter..." to the directory that your
   own directory that contains the MB2EML software.

5. Edit and run the script that will create the on-disk representation of
   your database that is required by the ORM package DBIx. Edit the lines indicated 
   in the source code to connect to your database. This script must be run for each
   database that you wish to use with MB2EML.

   % vi saveSchema.pl
   % ./saveSchema.pl

6. Edit and run the writeEML.pl program, specifying the database and dataset id you
   wish to create an XML document for:

   % vi writeEML.pl
   ./writeEML.pl


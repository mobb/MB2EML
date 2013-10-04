package MB2EML;

use strict;
use warnings;

our $VERSION;

$VERSION = '0.04';

1;

__END__

=head1 NAME

MB2EML - export data from Metabase to the Ecological Metadata Language

=head1 DESCRIPTION

The MB2EML package reads data from the PostgreSQL database schema I<Metabase> and writes out EML documents. 

The Metabase database schema was developed at the Georgia Costal Ecosystems LTER. Information regarding Metabase
can be found at 
https://gce-lter.marsci.uga.edu/public/app/resources.asp?type=document&category=informatics&theme=Database%20schemas/

=head2 Component Modules

=over 4

=item * B<Metabase.pm> queries Metabase using the Perl package DBIx. This package can use a static ("on disk") representation of the database schema in order to 
speed up construction of queries. See the README file for details on how to create this static schema.

=item * B<EML.pm> uses Metabase.pm to construct an object that contains all necessary data from Metabase. Once the data is assembled, the Perl Templating Toolkit is used to serialize the EML 
data to an XML document.

=back

=head1 REQUIREMENTS

=head2 Database

=over 4

=item * mb2eml schema/views

=item * PostgreSQL 9.x

=back

=head2 Perl modules

The following Perl modules must be installed on the machine running the MB2EML package.

=over 4

=item * DBIx::Class::Schema::Loader

=item * XML::LibXML

=item * Config::Simple

=back

The following Perl packages enable optional functionality and may be installed if needed:

=over 4

=item * Test::More
This package is used if regressing testing is going to be performed.

=back

=head2 EML 2.1.1 Distribution

The EML 2.1.1 distribution (Schema and EMLParser) are required to validate the EML document against the EML XML Schema and to
check identifiers in the document.  

The EML distribution is available from I<http://knb.ecoinformatics.org

=head1 CONFIGURATION

Configuration information for MB2EML is stored in the file ./config/mb2eml.ini and must be formatted
in the INI file format used by the Perl Config::Simple module. The format is simply

    identifier = value

The following configuration parameters are currently used:

=over 4

=item * account 

The PostgreSQL account name used to access Metabase

=item * pass 

The PostgreSQL password

=item * host 

The database server name

=item * port 

The database port number. For PostgreSQL the default value is '5432'.

=item * EMLlocation 

The location that contains the EML distribution that includes the EML XML Schema files and the KNB EMLParser program The
EML distribution can be obtained from the Knowledge Netwrok for Bicomplexity webset at:

=back

=over 4

=item L<http://knb.ecoinformatics.org/software/eml/>
EMLlocation can be specified as:

=over 4 

=item * a web URL, for example B<http://sbc.lternet.edu/external/InformationManagement/EML_211_schema/>

=item * a file URL, for example B<file:///Users/peter/eml-2.1.1/eml.xsd>

=item * a local directory, for example B</Users/peter/eml-2.1.1>

=back

=back

Note that if a web URL is specified, then the EMLParser program cannot be run because the EML distribution must be in a local directory.

A sample configuration file named B<./config/mb2eml.ini.sample> is included with the MB2EML distribution.

=head1 TEMPLATES

The Perl Templating Toolkit is used to render the EML data to XML.
The data processed by each template correspond to one EML module, for example the template I<eml-coverage.tt> corresponds to the EML module
I<eml-covreage>.

This makes the templates easier to edit and allows one template to be used at different levels in the hierarchy, for example the eml-methods.tt template can be used to describe methods at any of the following levels in the EML document: ./eml/dataset, ./eml/dataset/dataTable 

=head1 TESTING

Please see the documentation for ./tests/mb2eml-test.pl

=head1 MAINTENANCE

MB2EML currently implements a subset of all possible EML modules. This section provides a brief guide for updating MB2EML to
use new EML modules, or to use additional elements in currently implemented modules.

The MB2EML templates are in the ./templates directory. Each template file corresponds to an EML module, for example eml-contacts.tt corresponds to the EML module of the same name.
Please note that an EML module may contain data from one or more database views. 
For example, the EML module eml-attribute is rendered using the template file templates/eml-attribute.tt and is supplied with data from the view vw_eml_attributelist. 
The EML module eml-coverage however, requires data from multiple database views: vw_eml_geographiccoverage, vw_eml_taxonomiccoverage, vw_eml_temporalcoverage.

=head2 Adding a new view

The changes necessary to implement a new view will be shown by using an example of adding
the view "vw_eml_geographiccoverage" to MB2EML. As this view is already added to MB2EML you
can view the source files for further details.

=over 4

=item * add accessor method to Metabase.pm

sub getGeographicCoverage { ... }

The method I<getGeographicCoverage> queries Metabase for geographic coverage metadata. Data will be returned for either the EML dataset level
or the entity level depending on the value of $entity_sort_order. The value '0' is used to retrieve dataset coverage and any other value will
retrieve coverage information for the entity with the specified I<entity_sort_order>.

Note that the DBIx::Class::ResultSet is returned in the variable I<$rs>, which requires an iterator (i.e. $rs->next) to process. 
The getGeographicCoverage method reformats this resultSet into an array for easier processing by the calling program.

=item * add attribute to EML.pm

=item * add accessor method to EML.pm

=item * insert data from accessor into %dataset

=back 

For each new view added to the PostgreSQL mb2eml schema, add an accessor method that will retrieve information from the view. For example, 
the accessor getContacts retrieves records from the vw_eml_contact view. Currently there are two types of database accessor methods: 
1. methods that return a single result 
2. methods that return an array of results. 
Note that the data object returned by the accessor is either a single Perl DBIC row or an array of DBIC rows.

=head1 AUTHOR

Peter Slaughter "<pslaughter@msi.ucsb.edu>"

=cut


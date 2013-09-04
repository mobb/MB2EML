#!/usr/bin/env perl

use Getopt::Std;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;
use Config::Simple;

# Load config file
my $cfg = new Config::Simple('config/mb2eml.ini');
my $dumpDir = "./lib";
use vars qw/ %opt /;

# get PostgreSQL account and pass
my $account = $cfg->param('account');
my $pass = $cfg->param('pass');
my $host = $cfg->param('host');

# List of databases to create schemas for.
my @databases = ("mcr_metabase", "sbc_metabase");
my $dbi = "";
my $schema = "";
my $schemaOptions; 

# Get command line options
# The '-u' command line option causes saveSchema.pl to update
# an existing static (on-disk) schema.
# The '-o' command line option causes DBIx to overwrite any
# changes to the "non-editable" portions of the schema files.
getopts('uo', \%opt);

foreach $db (@databases) {

    my $schemaDir = $dumpDir . "/" . $db;

    if (! -e $schemaDir || $opt{u} ) {
        $schema = $db . "::Schema";
        $dbi = 'dbi:Pg:dbname=' . $db . ';host=' . $host ;

        if ($opt{o}) {
            $schemaOptions = { debug => 1,
                  db_schema => 'mb2eml',
                  preserve_case => 1,
                  constraint => qr/vw.*/,
                  dump_directory => $dumpDir,
                  overwrite_modifications => 1,
                  naming => { monikers => 'preserve', relationships => 'preserve' }};
        } else {
            $schemaOptions = { debug => 1,
                  db_schema => 'mb2eml',
                  preserve_case => 1,
                  constraint => qr/vw.*/,
                  dump_directory => $dumpDir,
                  naming => { monikers => 'preserve', relationships => 'preserve' }};
        }

        make_schema_at(
            $schema,
            $schemaOptions,
            [ $dbi, $account, $pass] );
    } else {
        print "Directory ${dumpDir}/${db}" . " already exists. Use \"-u to overwrite it.\"\n";
    }
}

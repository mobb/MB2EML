#!/usr/bin/env perl

use DBIx::Class::Schema::Loader qw/ make_schema_at /;
use Config::Simple;

# Load config file
my $cfg = new Config::Simple('config/mb2eml.ini');

# get PostgreSQL account and pass
my $account = $cfg->param('account');
my $pass = $cfg->param('pass');
my $host = $cfg->param('host');

# List of databases to create schemas for.
my @databases = ("mcr_metabase", "sbc_metabase");
my $dbi = "";
my $schema = "";

foreach $db (@databases) {

    $schema = $db . "::Schema";
    $dbi = 'dbi:Pg:dbname=' . $db . ';host=' . $host ;
    make_schema_at(
        $schema,
        { debug => 1,
          db_schema => 'mb2eml',
          # Use this option to prepend database schema name to table names, i.e. 'scratch.vw_eml_creator_V3'
          # qualify_objects => 1,
          # Preserve case of database names
          #preserve_case => 1,
          constraint => qr/vw.*/,
          dump_directory => './lib',
          naming => { monikers => 'preserve', relationships => 'preserve' }
        }, [ $dbi, $account, $pass],
);
}


#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use DBI;
use Test::mysqld;

use Test::HandyData::mysql;


main();
exit(0);


# 

sub main {
    
    my $mysqld = Test::mysqld->new( my_cnf => { 'skip-networking' => '' } )
        or plan skip_all => $Test::mysqld::errstr;

    my $dbh = DBI->connect(
                $mysqld->dsn(dbname => 'test')
    ) or die $DBI::errstr;
    $dbh->{RaiseError} = 1;

    $dbh->do(q{
        CREATE TABLE table1 (
            id integer primary key auto_increment
        )
    });
    $dbh->do(q{
        CREATE TABLE table2 (
            id integer primary key
        )
    });
    $dbh->do(q{
        CREATE TABLE table3 (
            id integer
        )
    });

    my ($td, $def, $cd);

    $td = Test::HandyData::mysql::TableDef->new(dbh => $dbh, table_name => 'table1');
    $def = $td->def();
    $cd = Test::HandyData::mysql::ColumnDef->new('id', $def->{id});
    is($cd->is_auto_increment(), 1);

    $td = Test::HandyData::mysql::TableDef->new(dbh => $dbh, table_name => 'table2');
    $def = $td->def();
    $cd = Test::HandyData::mysql::ColumnDef->new('id', $def->{id});
    is($cd->is_auto_increment(), 0);

    $td = Test::HandyData::mysql::TableDef->new(dbh => $dbh, table_name => 'table3');
    $def = $td->def();
    $cd = Test::HandyData::mysql::ColumnDef->new('id', $def->{id});
    is($cd->is_auto_increment(), 0);


    $dbh->disconnect();

    done_testing();
}


#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use DBI;
use Test::mysqld;

use HandyDataGen::mysql;

my $CLASS_NAME = 'HandyDataGen::mysql::TableDef';

main();
exit(0);


#   _table_def 

sub main {
    
    my $mysqld = Test::mysqld->new( my_cnf => { 'skip-networking' => '' } )
        or plan skip_all => $Test::mysqld::errstr;

    my $dbh = DBI->connect(
                $mysqld->dsn(dbname => 'test')
    ) or die $DBI::errstr;
    $dbh->{RaiseError} = 1;
    my $hd = HandyDataGen::mysql->new(dbh => $dbh);

    $dbh->do(q{CREATE TABLE table1 (
        id integer primary key auto_increment,
        name varchar(20) not null
    )});


    my $table_def = $hd->_table_def('table1');
    is(ref $table_def, $CLASS_NAME);
    is(ref $hd->{_table_def}{table1}, $CLASS_NAME);


    #  I don't care whether a table exists or not,
    #  because actual table definition would be retrieved when it actually needed.
    $table_def = $hd->_table_def('table2');
    is(ref $table_def, $CLASS_NAME);
    is(ref $hd->{_table_def}{table2}, $CLASS_NAME);


    $dbh->disconnect();

    done_testing();
}


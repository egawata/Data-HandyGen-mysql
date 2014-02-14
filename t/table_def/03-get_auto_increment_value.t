use strict;
use warnings;

use Test::More tests => 3;
use DBI;

use Data::HandyGen::mysql;
use Data::HandyGen::mysql::TableDef;
use Test::mysqld;


main();
exit(0);


sub main {
    my $mysqld = Test::mysqld->new( my_cnf => { 'skip-networking' => '' } )
        or die $Test::mysqld::errstr;
        
    my $dbh = DBI->connect($mysqld->dsn(dbname => 'test'))
        or die $DBI::errstr;
        
    $dbh->do(q{SET GLOBAL log = 1});
    test_table_with_auto_increment_col($dbh);
    test_table_with_no_auto_increment_col($dbh);
    
    $dbh->disconnect(); 
}


sub test_table_with_auto_increment_col {
    my ($dbh) = @_;

    $dbh->do(q{
        CREATE TABLE table_test_0 (
            id integer primary key auto_increment
        )
    });

    my $td = Data::HandyGen::mysql::TableDef->new(dbh => $dbh, table_name => 'table_test_0');
    my $id = $td->get_auto_increment_value();
    is($id, 1);

    $dbh->do(q{ALTER TABLE table_test_0 AUTO_INCREMENT = 100});

    $id = $td->get_auto_increment_value();
    is($id, 100);
}


sub test_table_with_no_auto_increment_col {
    my ($dbh) = @_;

    $dbh->do(q{
        CREATE TABLE table_test_1 (
            id integer primary key
        )
    });
    my $td = Data::HandyGen::mysql::TableDef->new(dbh => $dbh, table_name => 'table_test_1');
    my $id = $td->get_auto_increment_value();
    is($id, undef);
}
 



#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 6;
use DBI;
use Test::mysqld;

use Test::HandyData::mysql;


main();
exit(0);


=pod

get_cols_requiring_value のテスト


=cut

sub main {

    my $mysqld = Test::mysqld->new( my_cnf => { 'skip-networking' => '' } )
        or plan skip_all => $Test::mysqld::errstr;

    my $dbh = DBI->connect(
                $mysqld->dsn(dbname => 'test')
    ) or die $DBI::errstr;
    $dbh->{RaiseError} = 1;

    test_0($dbh); 
    test_1($dbh);
    test_2($dbh);

    $dbh->disconnect;
}


=pod test_0

auto_increment 列は結果から除外される。
ただしユーザから指定があれば結果に含まれる。


=cut

sub test_0 {
    my ($dbh) = @_;

    $dbh->do(q{
        CREATE TABLE table_test_0 (
            id      integer primary key auto_increment
        )
    });

    my $hd = Test::HandyData::mysql->new(dbh => $dbh);

    my $cols = $hd->get_cols_requiring_value('table_test_0');
    is_deeply($cols, []);

    $hd->_set_user_valspec('table_test_0', { id => 100 });
    $cols = $hd->get_cols_requiring_value('table_test_0');
    is_deeply($cols, ['id']);
}


=pod test_1

defalut 値が設定されていればそれを使用するので、結果から除外する。
ただしユーザから指定された場合はそれを使用するので、結果に含まれる。

* 外部キー制約がある場合に不具合が出るため、デフォルト値でのユーザ指定があった場合と同様に処理

=cut

sub test_1 {
    my ($dbh) = @_;

    $dbh->do(q{
        CREATE TABLE table_test_1 (
            id      integer not null default 100 
        )
    });

    my $hd = Test::HandyData::mysql->new(dbh => $dbh);

    my $cols = $hd->get_cols_requiring_value('table_test_1');
    is_deeply($cols, ['id']);

    $hd->_set_user_valspec('table_test_1', { id => 200 });
    $cols = $hd->get_cols_requiring_value('table_test_1');
    is_deeply($cols, ['id']);
}



=pod test_2

NULLABLE 列であれば、NULLのままにしておくため、結果から除外する。
ただしユーザから指定された場合はそれを使用するので、結果に含める。

=cut

sub test_2 {
    my ($dbh) = @_;

    $dbh->do(q{
        CREATE TABLE table_test_2 (
            id      integer 
        )
    });

    my $hd = Test::HandyData::mysql->new(dbh => $dbh);

    my $cols = $hd->get_cols_requiring_value('table_test_2');
    is_deeply($cols, []);

    $hd->_set_user_valspec('table_test_2', { id => 30 });
    $cols = $hd->get_cols_requiring_value('table_test_2');
    is_deeply($cols, ['id']);
}





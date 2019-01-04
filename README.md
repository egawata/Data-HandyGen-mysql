# NAME

Data::HandyGen::mysql - Generates test data for mysql easily.

# VERSION

This documentation refers to Data::HandyGen::mysql version 0.0.5

# SYNOPSIS

    use DBI;
    use Data::HandyGen::mysql;

    my $dbh = DBI->connect('dbi:mysql:test', 'user', 'pass');

    my $hd = Data::HandyGen::mysql->new( fk => 1 );
    $hd->dbh($dbh);


    #  -- table definitions --
    #
    #  create table category (
    #      id           integer primary key,
    #      name         varchar(20) not null
    #  );
    #
    #  create table item (
    #      id           integer primary key auto_increment,
    #      category_id  interger not null,
    #      name         varchar(20) not null,
    #      price        integer not null,
    #      constraint foreign key (category_id) references category(id)
    #  );


    #  1.
    #  Insert one row to 'item'.
    #  'category_id', 'name' and 'price' will be random values.
    #  category_id refers to category.id, so the value will be selected one of values in category.id.
    #  If table 'category' has no record, new record will be added to 'category'.

    my $id = $hd->insert('item');

    #  Result example:
    #  [item]
    #           id: 1
    #  category_id: 497364651
    #         name: name_1
    #        price: 597348646
    #
    #  [category]
    #           id: 497364651
    #         name: name_497364651
    #

    print "ID: $id\n";      #  'ID: 1'


    #  2.
    #  Insert one row to 'item' with name = 'Banana'.
    #  category_id and price will be random values.

    $id = $hd->insert('item', { name => 'Banana' });  #  Maybe $id == 2

    #  Result example:
    #  [item]
    #           id: 2
    #  category_id: 497364651
    #         name: Banana
    #        price: 337640949
    #
    #  [category]
    #           id: 497364651
    #         name: name_497364651


    #  3.
    #  Insert one row to 'item' with category_id one of 10, 20 or 30 (selected randomly).
    #  If table 'category' has no record with id = 10, 20 nor 30,
    #  a record having one of those ids will be generated on 'category'.

    $hd->insert('item', { category_id => [ 10, 20, 30 ] });

    #  Result example:
    #  [item]
    #           id: 3
    #  category_id: 20
    #         name: name_3
    #        price: 587323402
    #
    #  [category]
    #           id: 20
    #         name: name_20


    #  4.
    #  If you're interested also in category name, do this.

    $cat_id = $hd->insert('category', { name => 'Fruit' });
    $item_id = $hd->insert('item', { category_id => $cat_id, name => 'Coconut' });


    #  Delete all records inserted by $hd
    $hd->delete_all();

    #  ...Or retrieve all IDs for later deletion.
    my $ids = $hd->inserted();

# DESCRIPTION

This module generates test data and insert it into mysql tables. You only have to specify values of columns you're really interested in. Other necessary values are generated automatically.

When we test our product, sometimes we need to create test records, but generating them is a tedious task. We should consider many constraints (not null, foreign key, etc.) and set values to many columns in many tables, even if we want to do small tests, are interested in only a few columns and don't want to care about others. Maybe this module get rid of much of those unnecessary task.

# METHODS

## new(dbh => $dbh, fk => $fk)

Constructor. `dbh` is required to be specified at here, or by calling `$obj->dbh($dbh)` later. `fk` is optional.

## dbh($dbh)

set a database handle

## fk($flag)

If specified 1, it also creates records on other tables referred by foreign key columns in main table, if necessary.

Default is 0 (doesn't add records to other tables), so if you want to use this functionality, you need to specify 1 explicitly.

## insert($table\_name, $valspec)

Inserts a record to a table named $table\_name.

You can specify values of each column(s) with $valspec, a hashref which keys are columns' names in $table\_name.

    $hd->insert('table1', {
        id      => 5,
        price   => 300
    });

### format

- colname => $scalar

    specifies a value of 'colname'

        $hd->insert('table1', { id => 5 });      #  id will become 5

- colname => \[ $val1, $val2, ... \]

    value of 'colname' will be randomly chosen from $val1, $val2, ...

        $hd->insert('table1', { id => [ 10, 20, 30 ] })      #  id will become one of 10, 20 or 30

- colname => { random => \[ $val1, $val2, ... \] }

    verbose expression of above

- colname => qr/$pattern/

    value of 'colname' is determined by $pattern.

    NOTE: This function uses randregex of `String::Random`, which does not handles real regular expression.

        $hd->insert('table1', { filename => qr/[0-9a-f]{8}\.jpg/ });  #  'a1b2c3d4.jpg'

- colname => { random => qr/$pattern/ }

    verbose expression of above

- colname => { range => \[ $min, $max \] }

    value of 'colname' is determined between $min and $max ($min inclusive, $max exclusive). Can be used only for number(int, double, numeric, etc.).

- colname => { dt\_range => \[ $start\_datetime, $end\_datetime \] }

    value of 'colname' is determined between $start\_datetime and $end\_datetime ($start\_datetime inclusive, $end\_datetime exclusive). Can be used only for date or datetime type.

        $hd->insert('table1', {
            purchase_datetime => { dt_range => [ '2013-07-20 12:00:00', '2013-7-21 14:00:00' ] }
        });

        $hd->insert('table2', {
            exec_datetime => { dt_range => [ '2013-08-01', '2013-08-05' ] }     #  time can be ommitted
        });

### return value

Returns a value of primary key. (Only when primary key exists and it contains only a single column. Otherwise returns undef.)

## inserted()

Returns all primary keys of inserted records by this instance. Returned value is a hashref like this:

    my $ret = $hd->inserted();

    #  $ret = {
    #    'table_name1' => [ 10, 11 ],
    #    'table_name2' => [ 100, 110, 120 ],
    #  };

CAUTION: inserted() ignores records with no primary key, or primary key with multiple columns.

## delete\_all()

deletes all rows inserted by this instance.

CAUTION: delete\_all() won't delete rows in tables which don't have primary key, or which have primary key with multiple columns.

# BUGS AND LIMITATIONS

There are still many limitations with this module. I'll fix them later.

Please report problems to Egawata `(egawa.takashi at gmail com)`
Patches are welcome.

### Only primary key with single column is supported.

Although it works when inserting a record into a table which primary key consists of multiple columns, `insert()` won't return a value of primary key just inserted.

### Foreign key constraint which has multiple columns is not supported.

For now, if you want to use this module with such a table, specify those values explicitly.

### Multiple foreign key constraints to the same column are not supported.

For now, if you want to use this module with such a table, specify those values explicitly.

### Some data types are not supported.

For example, `blob` or `set` aren't supported. The values of those columns won't be auto-generated.

# AUTHOR

Takashi Egawa (`egawa.takashi at gmail com`)

# LICENCE AND COPYRIGHT

Copyright (c)2012-2018 Takashi Egawa (`egawa.takashi at gmail com`). All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See [perlartistic](https://metacpan.org/pod/perlartistic).

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

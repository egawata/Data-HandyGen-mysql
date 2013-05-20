use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Test::HandyData::mysql',
    VERSION_FROM      => 'lib/Test/HandyData/mysql.pm', # finds $VERSION
    PREREQ_PM         => {
        "DBI"                   => 1.38,
        "SQL::Maker"            => 0,
        "Class::Accessor::Lite" => 0,
        "Test::More"            => '0.87_01',
        "Test::Exception"       => 0,
        "Test::mysqld"          => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Test/HandyData/mysql.pm', # retrieve abstract from module
       AUTHOR         => 'Takashi Egawa <egawa.takashi@gmail.com>') : ()),
);

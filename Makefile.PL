use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'HURON',
    AUTHOR              => q{Daniel Perrett <perrettdl@googlemail.com>},
    VERSION_FROM        => 'lib/HURON.pm',
    ABSTRACT_FROM       => 'lib/HURON.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'HURON-*' },
);

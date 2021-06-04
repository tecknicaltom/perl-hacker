use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'PerlHacker',
    AUTHOR           => q{Tom Samstag <github@modtwo.com>},
    VERSION_FROM     => 'lib/PerlHacker.pm',
    ABSTRACT_FROM    => 'lib/PerlHacker.pm',
    LICENSE          => 'gpl_3',
    PL_FILES         => {},
    MIN_PERL_VERSION => '5.006',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => '0',
    },
    BUILD_REQUIRES => {
        'Test::More' => '0',
    },
    PREREQ_PM => {
        #'ABC'              => '1.6',
        #'Foo::Bar::Module' => '5.0401',
    },
    EXE_FILES => [
        'bin/analyze-elf',
        'bin/pattern_create',
        'bin/pattern_offset',
    ],
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'PerlHacker-*' },
);

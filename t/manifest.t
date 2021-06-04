#!perl
use 5.006;
use strict;
use warnings;
use Test::More qw(no_plan);
use ExtUtils::Manifest;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

is_deeply [ ExtUtils::Manifest::manicheck() ], [], 'missing';
is_deeply [ ExtUtils::Manifest::filecheck() ], [], 'extra';

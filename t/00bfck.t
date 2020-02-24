#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use File::Temp;
use Module::Build::Parse::Yapp;
use Test::Simple tests => 1;

my $tempdir = File::Temp::tempdir( DIR => 't', CLEANUP => 1 );

my $inputfile  = File::Spec->catdir( $tempdir, 'bfck.yp' );
my $outputfile = File::Spec->catdir( $tempdir, 'bfck.pm' );

open( my $yp, '>', $inputfile );
print $yp <<END;
# Parser for the Brainfuck programming language

%%

program: #empty
       | program instruction
       ;

instruction: '>' | '<' | '+' | '-' | '.' | ',' | '[' | ']' ;

%%
END
close $yp;

Module::Build::Parse::Yapp::_make_parser( $inputfile,
                                          $outputfile,
                                          'bfck' );

ok( -e $outputfile, 'parser is generated' );

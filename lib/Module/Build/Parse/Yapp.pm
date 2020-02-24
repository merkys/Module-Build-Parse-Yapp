package Module::Build::Parse::Yapp;

use strict;
use warnings;
use base 'Module::Build';

# ABSTRACT: builds Parse::Yapp parsers from source

use File::Find;
use File::Spec::Functions;
use Parse::Yapp;

sub new {
    my $self = shift;
    my %args = @_;
    $self->SUPER::new( %args );
}

sub process_yp_files {
    my $self = shift;

    find( { wanted => \&_find_parser, no_chdir => 1 }, 'lib' );
}

sub _find_parser {
    return unless /\.yp$/;

    my $pmfile = $_;
    $pmfile =~ s/\.yp$/.pm/;

    my @path = splitdir( $File::Find::name );
    my @pmpath = my @namespace = @path;

    unshift @pmpath, 'blib';
    $pmpath[-1] =~ s/\.yp$/.pm/;

    shift @namespace;
    $namespace[-1] =~ s/\.yp$//;

    _make_parser( $File::Find::name,
                  catdir( @pmpath ),
                  join '::', @namespace );
}

sub _make_parser {
    my( $inputfile, $outputfile, $classname ) = @_;

    my $parser = Parse::Yapp->new( inputfile => $inputfile );
    open( my $out, '>', $outputfile );
    print $out $parser->Output( classname => $classname );
    close $out;
}

1;

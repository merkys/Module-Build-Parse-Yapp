package Module::Build::Parse::Yapp;

use strict;
use warnings;
use base 'Module::Build';

use File::Find;
use File::Spec;
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

    my $parser = Parse::Yapp->new( inputfile => $File::Find::name );

    my $pmfile = $_;
    $pmfile =~ s/\.yp$/.pm/;

    my @path = File::Spec->splitdir( $File::Find::name );
    my @pmpath = my @namespace = @path;

    unshift @pmpath, 'blib';
    $pmpath[-1] =~ s/\.yp$/.pm/;

    shift @namespace;
    $namespace[-1] =~ s/\.yp$//;

    open( my $out, '>', File::Spec->catdir( @pmpath ) );
    print $out $parser->Output( classname => join '::', @namespace );
    close $out;
}

1;

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

    find( { wanted => \&_find_parser }, 'lib' );
}

sub _find_parser {
    return unless /\.yp$/;

    my $parser = Parse::Yapp->new( inputfile => $_ );

    my $pmfile = $_;
    $pmfile =~ s/\.yp$/.pm/;

    my @namespace = File::Spec->splitdir( $File::Find::name );
    shift @namespace;
    $namespace[-1] =~ s/\.yp$//;

    open( my $out, '>', $pmfile );
    print $out $parser->Output( classname => join '::', @namespace );
    close $out;
}

1;

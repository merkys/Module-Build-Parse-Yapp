package Module::Build::Parse::Yapp;

use strict;
use warnings;
use base 'Module::Build';

# ABSTRACT: build Parse::Yapp parsers from source

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

=head1 NAME

Module::Build::Parse::Yapp - build Parse::Yapp parsers from source

=head1 AUTHOR

Andrius Merkys <merkys@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2020 Andrius Merkys

This is free software, licensed under the three-clause BSD License.

=head1 SEE ALSO

perl(1), Module::Build(3), Parse::Yapp(3)

=cut

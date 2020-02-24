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

=head1 SYNOPSIS

    use Module::Build;
    my $build = Module::Build::Parse::Yapp->new
        (
            module_name => 'Foo::Bar',
            ...other stuff here...
        );
    $build->add_build_element('yp');
    $build->create_build_script;

=head1 SEE ALSO

perl(1), Module::Build(3), Parse::Yapp(3)

=cut

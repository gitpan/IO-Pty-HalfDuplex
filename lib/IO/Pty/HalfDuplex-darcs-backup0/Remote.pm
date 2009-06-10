#!/usr/bin/env perl
package IO::Pty::HalfDuplex::Remote;
use strict;
use warnings;

use Carp;
use IPC::Open2;

our $VERSION = '0.01';

sub new {
    my $class = shift;

    bless {}, $class;
}

sub connect {
    my $self = shift;

    $self = $self->new unless ref $self;

    croak "already connected" if $self->is_active;

    open2($self->{reader}, $self->{writer}, @_);

    $self;
}

sub read {
    my $self = shift;

    print {$self->{writer}} "\xFF\x00" or die "Cannot send EOO: $!\n";

    my $bu = "";
    my $lastFF = 0;

    while (1) {
        my $b = getc $self->{reader};
        if (!defined $b) {
            # Program is over.
            $self->close;

            return $bu;
        }

        if ($b eq "\0" && $lastFF) {
            return $bu;
        }

        if (!$lastFF && $b eq "\xFF") {
            $lastFF = 1;
            next;
        }

        $bu .= $b;
        $lastFF = 0;
    }
}

sub write {
    my ($self, $text) = @_;

    $text =~ s/\xFF/\xFF\xFF/g;
    print {$self->{writer}} $text;
}

sub is_active {
    my ($self) = @_;

    return defined $self->{reader};
}

sub kill {
    my ($self) = @_;

    close $self->{writer};
    close $self->{reader};

    $self->{reader} = $self->{writer} = undef;
}

sub close { shift->kill }

sub import {
    

1;

__END__

=head1 NAME

IO::HalfDuplex - ??

=head1 SYNOPSIS

    use IO::HalfDuplex;

=head1 DESCRIPTION



=head1 AUTHOR

Stefan O'Rear, C<< <stefanor@cox.net> >>

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-io-halfduplex at rt.cpan.org>, or browse
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-HalfDuplex>.

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Stefan O'Rear.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


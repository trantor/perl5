package Test::Builder::Result::Diag;
use strict;
use warnings;

use base 'Test::Builder::Result';

use Scalar::Util();
use Test::Builder::Util qw/accessors try/;
use Encode();
accessors qw/message/;

my $NORMALIZE = try { require Unicode::Normalize; 1 };

sub to_tap {
    my $self = shift;

    chomp(my $msg = $self->message);

    if ($self->trace && $self->trace->report) {
        my $encoding = $self->trace->encoding;
        if ($encoding && $encoding ne 'legacy') {
            my $file = $self->trace->report->file;
            my $decoded;
            try { $decoded = Encode::decode($encoding, "$file", Encode::FB_CROAK) };
            if ($decoded) {
                $decoded = Unicode::Normalize::NFKC($decoded) if $NORMALIZE;
                $msg =~ s/$file/$decoded/g;
            }
        }
    }

    $msg = "# $msg" unless $msg =~ m/^\n/;
    $msg =~ s/\n/\n# /g;
    return "$msg\n";
}

sub linked {
    my $self = shift;

    if (@_) {
        ($self->{linked}) = @_;
        Scalar::Util::weaken($self->{linked}) if defined $self->{linked};
    }

    return $self->{linked};
}

1;

__END__

=head1 NAME

Test::Builder::Result::Diag - Diag result type

=head1 DESCRIPTION

The diag result type.

=head1 METHODS

See L<Test::Builder::Result> which is the base class for this module.

=head2 CONSTRUCTORS

=over 4

=item $r = $class->new(...)

Create a new instance

=back

=head2 SIMPLE READ/WRITE ACCESSORS

=over 4

=item $r->message

The message in the note.

=item $r->trace

Get the test trace info, including where to report errors.

=item $r->pid

PID in which the result was created.

=item $r->depth

Builder depth of the result (0 for normal, 1 for subtest, 2 for nested, etc).

=item $r->in_todo

True if the result was generated inside a todo.

=item $r->source

Builder that created the result, usually $0, but the name of a subtest when
inside a subtest.

=item $r->constructed

Package, File, and Line in which the result was built.

=item $r->linked

If this diag is linked to a specific L<Test::Builder::Result::Ok> object, this
will be set to the object. Note this is automatically turned into a weak
reference as it is assumed that the Ok will also link to this object. This is
to avoid cycled and memory leaks.

=back

=head2 INFORMATION

=over 4

=item $r->to_tap

Returns the TAP string for the plan (not indented).

=item $r->type

Type of result. Usually this is the lowercased name from the end of the
package. L<Test::Builder::Result::Ok> = 'ok'.

=item $r->indent

Returns the indentation that should be used to display the result ('    ' x
depth).

=back

=head1 AUTHORS

=over 4

=item Chad Granum E<lt>exodist@cpan.orgE<gt>

=back

=head1 SOURCE

The source code repository for Test::More can be found at
F<http://github.com/Test-More/test-more/>.

=head1 COPYRIGHT

Copyright 2014 Chad Granum E<lt>exodist7@gmail.comE<gt>.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

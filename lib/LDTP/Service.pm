package LDTP::Service;
# ABSTRACT: Handling the LDTP service

use Moo;
use MooX::Types::MooseLike::Base qw<Bool Int Str>;
use Carp;

with 'LDTP::Role::RPCHandler';

has windows_env => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    builder => 1,
);

has bin => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => 1,
);

has app => (
    is => 'rw',
);

sub _build_windows_env {
    my $self = shift;

    # first check %ENV
    $ENV{'LDTP_WINDOWS'} and return 1;
    $ENV{'LDTP_LINUX'}   and return 0;

    # now check the the host OS
    $^O =~ /win|mingw/i and return 1;

    # when all else fails, we assume we're not on Windows
    return 0;
}

sub _build_bin {
    my $self = shift;
    return $self->windows_env ? 'CobraWinLDTP.exe' : 'ldtp';
}

sub start {
    my $self = shift;
    my $bin  = $self->bin;
    my $pid  = open my $app, '-|', $bin;

    defined $pid or croak "Error starting LDTP app ($bin): $!";

    $self->app($app);

    return 1;
}

sub stop {
    my $self = shift;
    my $app  = $self->app or return 0;
    close $app or die "Can't close app: $!\n";
}

sub isalive {
    my $self = shift;
    my $res  = $self->_try('isalive');
    use DDP; p $res;
}

1;


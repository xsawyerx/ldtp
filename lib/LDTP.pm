package LDTP;
# ABSTRACT: Perl interface to LDTP (Linux Desktop Testing Project)

use Moo;
use MooX::Types::MooseLike::Base qw<Bool HashRef>;

use LDTP::Window;

with 'LDTP::Role::RPCHandler';

has poll_events => (
    is      => 'ro',
    isa     => HashRef,
    default => sub { {} },
);

has windows_env => (
    is      => 'ro',
    isa     => Bool,
    lazy    => 1,
    builder => 1,
);

sub _build_windows_env {
    my $self = shift;

    # first check %ENV
    $ENV{'LDTP_WINDOWS'} and return 1;
    $ENV{'LDTP_LINUX'}   and return 0;

    # now check the the host OS
    $^O =~ /win|mingw/i and return 1;

    return 0;
}

sub window {
    my $self = shift;
    my $name = shift;
    return LDTP::Window->new( name => $name, client => $self->client );
}

sub wait {
    my $self    = shift;
    my $timeout = shift || 5;
    $self->_try( 'wait', $timeout );
}

sub generatemouseevent {
    my $self = shift;
    my ( $x, $y, $event_type ) = @_;

    defined $event_type or $event_type = 'b1c';

    $self->_try( 'generatemouseevent', $x, $y, $event_type );
}

sub getapplist {
    my $self = shift;
    $self->_try('getapplist');
}

sub getwindowlist {
    my $self = shift;
    $self->_try('getwindowlist');
}

sub registerevent {
    my $self = shift;
    my ( $event_name, $fnname, @args ) = @_;

    $self->poll_events->{$event_name} = [ $fnname, \@args ];
    $self->_try( 'registerevent', $event_name );
}

sub deregisterevent {
    my $self       = shift;
    my $event_name = shift;

    delete $self->poll_events->{$event_name};
    $self->_try( 'deregisterevent', $event_name );
}

sub registerkbevent {}

sub deregisterkbevent {}

sub launchapp {
    my $self = shift;
    my ( $cmd, $args, $delay, $env, $lang ) = @_;

    defined $args  or $args = [];
    defined $delay or $delay = 0;
    defined $env   or $env   = 1;
    defined $lang  or $lang  = 'C';

    $self->_try( 'launchapp', $cmd, $args, $delay, $env, $lang );
}

sub getcpustat {
    my $self         = shift;
    my $process_name = shift;

    $self->_try( 'getcpustat', $process_name );
}

sub getmemorystat {
    my $self         = shift;
    my $process_name = shift;

    $self->_try( 'getmemorystat', $process_name );
}

sub getlastlog {
    my $self = shift;
    $self->_try('getlastlog');
}

sub getobjectnameatcoords {
    my $self      = shift;
    my $wait_time = shift;

    defined $wait_time or $wait_time = 0;

    $self->_try( 'getobjectnameatcoords', $wait_time );
}

sub startprocessmonitor {
    my $self = shift;
    my ( $process_name, $interval ) = @_;

    defined $interval or $interval = 2;

    $self->_try( 'startprocessmonitor', $process_name, $interval );
}

sub stopprocessmonitor {
    my $self         = shift;
    my $process_name = shift;

    $self->_try( 'stopprocessmonitor', $process_name );
}

sub keypress {
    my $self = shift;
    my $data = shift;

    $self->_try( 'keypress', $data );
}

sub keyrelease {
    my $self = shift;
    my $data = shift;

    $self->_try( 'keyrelease', $data );
}

sub closewindow {
    my $self        = shift;
    my $window_name = shift;

    defined $window_name or $window_name = '';

    $self->window($window_name)->close;
}

sub maximizewindow {
    my $self        = shift;
    my $window_name = shift;

    defined $window_name or $window_name = '';

    $self->window($window_name)->maximize;
}

sub minimizewindow {
    my $self        = shift;
    my $window_name = shift;

    defined $window_name or $window_name = '';

    $self->window($window_name)->minimize;
}

sub simulatemousemove {
    my $self = shift;
    my ( $src_x, $src_y, $dst_x, $dst_y, $delay ) = @_;

    defined $delay or $delay = 0.0;

    $self->_try(
        'simulatemousemove',
        $src_x, $src_y,
        $dst_x, $dst_y,
        $delay,
    );
}

sub delaycmdexec {
    my $self  = shift;
    my $delay = shift;
    $self->_try( 'delaycmdexec', $delay );
}

sub imagecapture {}
sub onwindowcreate {}
sub removecallback {}
sub method_missing {}

1;


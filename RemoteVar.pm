package Tie::RemoteVar;
use 5.006;
use strict;
our $VERSION = '0.02';
use Net::Server;
use Tie::RemoteVar::Callback;
use Tie::RemoteVar::Constant;
use Tie::RemoteVar::Tie;
$|=1;

our @ISA = qw(Tie::RemoteVar::Tie Tie::RemoteVar::Callback Net::Server);

sub new {
    my $pkg = shift;
    my %arg = @_;
    my $ref = bless {
	port  => $arg{port} || 1234,
	value => {},
	type => {},
    }, $pkg;
    $ref->{server}->{allow} = ref($arg{allow}) eq 'ARRAY' ? $arg{allow} : [$arg{allow}];
    return $ref;
}

sub process_request {
    my $pkg = shift;
    while( chomp( $_=<STDIN> ) ){
	my ($cmd, $id, $value) = /^<(.+?)>\s<(.+?)>(?:\s(.*))?/o;
	$callback{$cmd}->($pkg, $id, $value);
    }
}

sub startserver {
    print STDERR __PACKAGE__." $VERSION started ...\n";
    open STDERR, ">/dev/null";
    $_[0]->run(port => $_[0]->{port});
    close STDERR;
}


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Tie::RemoteVar - Share variables everywhere

=head1 SYNOPSIS

  use Tie::RemoteVar;

  # server side
  my $vs = Tie::RemoteVar->new(allow => '127.0.0.1');
  $vs->startserver;

  # client side
  tie(%HASH, 'Tie::RemoteVar', id => 'meatball');
  untie %HASH;

=head1 DESCRIPTION

Users can treat inter-process or even inter-host variables almost as normal ones using L<Tie::RemoteVar> instead of stereotypical tedious coding.

To use this facility, users need to setup a server first. It is simple. The only requirements are allowed hosts' addresses and server's port.

Localhost access is I<not> presumed valid before users make an explicit statement.

  my $vs = Tie::RemoteVar->new(
			       port => 1234    # default is 1234
			       allow => [ 
					  '127.0.0.1',
					  '140.112..+'
					  ],
			       );

then start it

  $vs->startserver;

After setup is completed, users are empowered to access variables across processes or hosts. Likewise, default port is I<1234> and default host is I<127.0.0.1>. Additionally, users need to specify the variable's identifier on server, which is similar to the C<key> used in C<shmget>. It is required in order to locate variable after program's termination.

  [$x =] tie(%HASH, 'Tie::RemoteVar', id => 'meatball');

  [$x =] tie(@ARRAY, 'Tie::RemoteVar',
	     addr => '127.0.0.1', port => 1234, id => 'spaghetti');

  [$x =] tie($SCALAR, 'Tie::RemoteVar',
	     port => 1234, id => 'YangZhou ChaoFan');

  untie $SCALAR;
  untie @ARRAY;
  untie %HASH;

Since variables must be preserved after termination of scripts, users cannot use B<untie> or B<undef> to destroy variables. Instead, L<Tie::RemoteVar> provides B<erase> to perform this task.

  $x->erase();

It will erase the variable stored on the server.

=head1 CAVEATS

=over 2

=item * Tie-filehandle is not supported.

=item * Cannot handle variables of complex structure.

=back

=head1 TO DO

Recursive copy of Perl datatypes.

=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.

=cut

package Tie::RemoteVar::Tie;
our $VERSION = '0.01';
$|=1;

use 5.006;
use strict;
use Net::Telnet;
use Tie::RemoteVar::Constant;

# ----------------------------------------------------------------------
# Communication with server
# ----------------------------------------------------------------------
sub talk {
    my $pkg = shift;
    my $inst = shift;
    my @arg = @_;
    @arg = grep{defined $_} map { s/\n/\\n/go; s/\t/\\t/go; $_ } @arg;

    my $cmd = join q//, "<$inst> <${$pkg}{id}> ", join($DELIMIT, @arg) , "\n";
    my $telnet = new Net::Telnet (
				  Host => $pkg->{addr},
				  Port => $pkg->{port},
				  Binmode => 1
				  );
    $telnet->put($cmd);
    my $ret = $telnet->getline();
    if( $ret =~ /^S<(.+)>/o ){
        (my $value = $1) =~ s/\\n/\n/go;
	$value =~ s/\\t/\t/go;
        return $value;
    }
    return undef;
}

# ----------------------------------------------------------------------
# Tie Tie Tie ...
# ----------------------------------------------------------------------
sub TIESCALAR {
    my $pkg = shift;
    my %arg = @_;
    die "No identifier\n" unless $arg{id};
    my $ref = bless {
	id => $arg{id},
	port => $arg{port} || DEFPORT,
	addr => $arg{addr} || DEFADDR,
    }, $pkg;
    $ref->talk('SETTYPE', SCALAR);
    return $ref;
}

sub TIEARRAY {
    my $pkg = shift;
    my %arg = @_;
    die "No identifier\n" unless $arg{id};
    my $ref = bless {
	id => $arg{id},
	port => $arg{port} || DEFPORT,
	addr => $arg{addr} || DEFADDR,
    }, $pkg;
    $ref->talk('SETTYPE', ARRAY);
    return $ref;
}

sub TIEHASH {
    my $pkg = shift;
    my %arg = @_;
    die "No identifier\n" unless $arg{id};
    my $ref = bless {
	id => $arg{id},
	port => $arg{port} || DEFPORT,
	addr => $arg{addr} || DEFADDR,
    }, $pkg;
    $ref->talk('SETTYPE', HASH);
    return $ref;
}

sub FETCH { $_[0]->talk('FETCH', $_[1]) }
sub STORE { $_[0]->talk('STORE', "$_[1]", "$_[2]") }
sub FETCHSIZE { $_[0]->talk('FETCHSIZE') }
sub STORESIZE { $_[0]->talk('STORESIZE', $_[1]) }
sub EXTEND { $_[0]->talk('EXTEND', $_[1]) }
sub EXISTS { $_[0]->talk('EXISTS', $_[1]) }
sub DELETE { $_[0]->talk('DELETE', $_[1]) }
sub CLEAR { $_[0]->talk('CLEAR', $_[1]) }
sub PUSH { my $pkg = shift; $pkg->talk('PUSH', @_) }
sub POP { $_[0]->talk('POP', $_[1]) }
sub SHIFT { $_[0]->talk('SHIFT', $_[1]) }
sub UNSHIFT { my $pkg = shift; $pkg->talk('UNSHIFT', @_) }

sub SPLICE { 
    my $pkg   = shift;
    my $offset = shift || 0;
    my $length = shift || $pkg->FETCHSIZE() - $offset;
    $pkg->talk('SPLICE', $offset, $length, @_)
}

sub FIRSTKEY { $_[0]->talk('FIRSTKEY', $_[0]->{id}) }
sub NEXTKEY { $_[0]->talk('NEXTKEY', $_[0]->{id}) }

sub erase { $_[0]->talk('ERASE') }


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Tie::RemoteVar::Tie - Tie::RemoteVar::Tie

=head1 COPYRIGHT

xern E<lt>xern@cpan.orgE<gt>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.


=cut

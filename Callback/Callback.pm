package Tie::RemoteVar::Callback;
use 5.006;
use strict;
require Exporter;
our @ISA = qw(Exporter);
use Tie::RemoteVar::Constant;
our %callback;
our @EXPORT = qw(%callback);
our $VERSION = '0.01';

sub send_success { print "S<$_[0]>\n" }
sub send_failure { print "F\n" }

$callback{SETTYPE} = sub {
    my ($pkg, $id, $value) = @_;
    if( !$value || ($pkg->{type}->{$id} && $pkg->{type}->{$id} != $value) ){
	send_failure;
	return;
    }
    $pkg->{type}->{$id} = $value;
    send_success;
};

$callback{STORE} = sub {
    my ($pkg, $id, $value) = @_;

    if($pkg->{type}->{$id} == SCALAR){
	$value =~ /^(.+)$DELIMIT/o;
	$pkg->{value}->{$id} = $1;
	send_success;
	return;
    }
    elsif($pkg->{type}->{$id} == ARRAY){
	if( $value =~ /^(\-?\d+)$DELIMIT(.+)/o ){
	    $pkg->{value}->{$id}->[$1] = $2;
	    send_success;
	    return;
	}
    }
    elsif($pkg->{type}->{$id} == HASH){
	if( $value =~ /^(.+?)$DELIMIT(.*)/o ){
	    $pkg->{value}->{$id}->{$1} = $2;
	    send_success;
	    return;
	}
    }
    send_failure;
};

$callback{FETCH} = sub {
    my ($pkg, $id, $key) = @_;

    if($pkg->{type}->{$id} == SCALAR){
	send_success($pkg->{value}->{$id});
	return;
    }
    elsif( $pkg->{type}->{$id} == ARRAY ){
	send_success($pkg->{value}->{$id}->[$key]);
	return;
    }
    elsif( $pkg->{type}->{$id} == HASH ){
	send_success($pkg->{value}->{$id}->{$key});
	return;
    }
    send_failure;
};

$callback{ERASE} = sub {
    my ($pkg, $id) = @_;
    if($pkg->{type}->{$id} == SCALAR){
	delete $pkg->{value}->{$id};
	delete $pkg->{type}->{$id};
	send_success;
	return;
    }
    elsif( $pkg->{type}->{$id} == ARRAY ){
	@{$pkg->{value}->{$id}} = ();
	delete $pkg->{value}->{$id};
	delete $pkg->{type}->{$id};
	send_success;
	return;
    }
    elsif( $pkg->{type}->{$id} == HASH ){
	%{$pkg->{value}->{$id}} = ();
	delete $pkg->{value}->{$id};
	delete $pkg->{type}->{$id};
	send_success;
	return;
    }
    send_failure;
};


$callback{FETCHSIZE} = sub {
    my ($pkg, $id) = @_;
    if( $pkg->{type}->{$id} == ARRAY ){
	send_success(scalar @{$pkg->{value}->{$id}});
	return;
    }
    send_failure;
    return;
};


$callback{STORESIZE} = sub {
    my ($pkg, $id, $count) = @_;
    my $oldsize = @{$pkg->{value}->{$id}};
    if ( $count > $oldsize ) {
	foreach ( $count - $oldsize .. $count ) {
	    push @{$pkg->{value}->{$id}}, undef;
	}
    } elsif ( $count < $oldsize ) {
	foreach ( 0 .. $oldsize - $count - 2 ) {
	    pop @{$pkg->{value}->{$id}};
	}
    }
    send_failure;
};

$callback{EXTEND} = sub {
    my ($pkg, $id, $count) = @_;
    $callback{STORESIZE}->( $pkg, $id, $count );
};

$callback{EXISTS} = sub {
    my ($pkg, $id, $index) = @_;

    if( $pkg->{type}->{$id} == ARRAY ){
	send_failure if !defined $pkg->{value}->{$id}->[$index] ||
	    $index >= @{$pkg->{value}->{$id}};
	return;
    }
    elsif( $pkg->{type}->{$id} == HASH ){
	send_failure unless exists $pkg->{value}->{$id}->{$index};
	return;
    }
    else {
	send_failure;
	return;
    }

    send_success;
};

$callback{DELETE} = sub {
    my ($pkg, $id, $index) = @_;

    if( $pkg->{type}->{$id} == ARRAY ){
	$pkg->{value}->{$id}->[$index] = undef;
    }
    elsif ($pkg->{type}->{$id} == HASH ){
	delete $pkg->{value}->{$id}->{$index};
    }
    else {
	send_failure;
    }

    send_success;
};

$callback{CLEAR} = sub {
    my ($pkg, $id) = @_;
    if( $pkg->{type}->{$id} == ARRAY ){
	$pkg->{value}->{$id} = [];
	send_success;
	return;
    }
    elsif ($pkg->{type}->{$id} == HASH ){
	%{$pkg->{value}->{$id}} = ();
	send_success;
	return;
    }

    send_failure;
};


$callback{PUSH} = sub {
    my ($pkg, $id, $value) = @_;
    push @{$pkg->{value}->{$id}}, $_ foreach split /$DELIMIT/o, $value;
    send_success( scalar @{$pkg->{value}->{$id}} );
};

$callback{POP} = sub {
    my ($pkg, $id) = @_;
    send_success( pop @{$pkg->{value}->{$id}} );
};

$callback{SHIFT} = sub {
    my ($pkg, $id) = @_;
    send_success( shift @{$pkg->{value}->{$id}} );
};

$callback{UNSHIFT} = sub {
    my ($pkg, $id, $value) = @_;
    unshift @{$pkg->{value}->{$id}}, $_ foreach split /$DELIMIT/o, $value;
    send_success( scalar @{$pkg->{value}->{$id}} );
};

$callback{SPLICE} = sub {
    my ($pkg, $id, $value) = @_;
    unless( $pkg->{type}->{$id} == ARRAY ){
	send_failure;
	return;
    }
    my @arg = split /$DELIMIT/o, $value;
    splice @{$pkg->{value}->{$id}}, shift @arg, shift @arg, @arg;
    send_success;
};

$callback{FIRSTKEY} = sub {
    my ($pkg, $id) = @_;
    unless ($pkg->{type}->{$id} == HASH) {
	send_failure();
	return;
    }
    keys %{$pkg->{value}->{$id}};
    send_success(each %{$pkg->{value}->{$id}});
};

$callback{NEXTKEY} = sub {
    my ($pkg, $id) = @_;
    unless ($pkg->{type}->{$id} == HASH) {
	send_failure();
	return;
    }
    send_success(each %{ $pkg->{value}->{$id} });
};



1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Tie::RemoteVar::Callback - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Tie::RemoteVar::Callback;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Tie::RemoteVar::Callback, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 COPYRIGHT

xern <xern@cpan.org>

This module is free software; you can redistribute it or modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<perl>.

=cut

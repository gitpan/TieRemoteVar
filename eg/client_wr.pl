#!/usr/bin/perl -Iblib/arch -Iblib/lib

use Tie::RemoteVar;
use Data::Dumper;


tie($SCALAR, 'Tie::RemoteVar', id => 'scalar');
$SCALAR = "it's cool, isn't it?";
print Dumper $SCALAR;
untie $SCALAR;

tie(@ARRAY, 'Tie::RemoteVar', id => 'array');
push @ARRAY, 1, 2, 3;
pop @ARRAY;
unshift @ARRAY, 3, 4;
splice @ARRAY, @ARRAY, 0, 7, 8, 9;
print Dumper \@ARRAY;
untie @ARRAY;


tie(%HASH, 'Tie::RemoteVar', id => 'hash');
@HASH{qw(qwer asdf zxcv vcxz fdsa rewq)} = qw(6 1 2 3 4 5);

print Dumper \%HASH;
untie @ARRAY;

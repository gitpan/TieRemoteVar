#!/usr/bin/perl -Iblib/arch -Iblib/lib

use Tie::RemoteVar;

$x = tie($SCALAR, 'Tie::RemoteVar', id => 'scalar');
print "<$SCALAR>\n";
print join q/ /, split //, $SCALAR;
print "\n";
print join q/ /, map {ord$_} split //, $SCALAR;
print "\n";
untie $SCALAR;


tie(@ARRAY, 'Tie::RemoteVar', id => 'array');
print join qq/:/, @ARRAY;
print $/;
untie @ARRAY;


$x = tie(%HASH, 'Tie::RemoteVar', id => 'hash');
print "$_ => $HASH{$_}\n" for sort keys %HASH;
untie %HASH;

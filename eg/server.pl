#!/usr/bin/perl -Iblib/arch -Iblib/lib
use Tie::RemoteVar;
my $vs = Tie::RemoteVar->new(allow => '127.0.0.1');
$vs->startserver;


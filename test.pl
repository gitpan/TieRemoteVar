use Test;
BEGIN { plan tests => 5 };
use Tie::RemoteVar;
ok(1);

my $pid = fork();
if(!$pid){
    my $vs = Tie::RemoteVar->new(allow => '127.0.0.1');
    open STDERR, ">/dev/null";
    $vs->startserver;
    close STDERR;
    exit;
}
else {
    sleep 3;
    my $pid2 = fork();
    if(!$pid2){
	tie($SCALAR, 'Tie::RemoteVar', id => 'scalar');
	$SCALAR = "it's cool, isn't it?";
	untie $SCALAR;
	
	tie(@ARRAY, 'Tie::RemoteVar', id => 'array');
	push @ARRAY, 1, 2, 3;
	pop @ARRAY;
	unshift @ARRAY, 3, 4;
	splice @ARRAY, @ARRAY, 0, 7, 8, 9;
	$ARRAY[0] = 3;
	untie @ARRAY;

	tie(%HASH, 'Tie::RemoteVar', id => 'hash');
	@HASH{qw(qwer asdf zxcv vcxz fdsa rewq)} = qw(0 1 2 3 4 5);
	untie @ARRAY;
	exit;
    }
    wait;

    tie($SCALAR, 'Tie::RemoteVar', id => 'scalar');
    ok($SCALAR, "it's cool, isn't it?");
    untie $SCALAR;

    tie(@ARRAY, 'Tie::RemoteVar', id => 'array');
    ok($ARRAY[0], 3);
    ok($ARRAY[5], 8);
    untie @ARRAY;

    tie(%HASH, 'Tie::RemoteVar', id => 'hash');
    ok($HASH{asdf}, 1);
    untie @ARRAY;
}

kill 9, $pid;

package Tie::RemoteVar::Constant;

use 5.006;
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(
SCALAR
ARRAY
HASH
DEFPORT
DEFADDR
$DELIMIT
);
our $VERSION = '0.01';

use constant SCALAR  => 1;
use constant ARRAY   => 2;
use constant HASH    => 3;

use constant DEFPORT => 1234;
use constant DEFADDR => '127.0.0.1';

our $DELIMIT = "\t";

1;
__END__

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Tie::RemoteVar',
    'VERSION_FROM'	=> 'RemoteVar.pm', # finds $VERSION
    'PREREQ_PM'		=> {
	'Net::Server' => '0.84',
	'Net::Telnet' => '3',
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'RemoteVar.pm', # retrieve abstract from module
       AUTHOR     => 'xern <xern@cpan.org>') : ()),
);

use ExtUtils::MakeMaker;


WriteMakefile(
    'NAME'		=> 'Tie::RemoteVar::Constant',
    'VERSION_FROM'	=> 'Constant.pm', 
    'PREREQ_PM'		=> {}, 
    ($] >= 5.005 ?    (AUTHOR     => 'xern <xern@cpan.org>') : ()),
);

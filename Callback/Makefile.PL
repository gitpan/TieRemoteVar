use ExtUtils::MakeMaker;


WriteMakefile(
    'NAME'		=> 'Tie::RemoteVar::Callback',
    'VERSION_FROM'	=> 'Callback.pm', 
    'PREREQ_PM'		=> {}, 
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Callback.pm', 
       AUTHOR     => 'xern <xern@cpan.org>') : ()),
);

use ExtUtils::MakeMaker;


WriteMakefile(
    'NAME'		=> 'Tie::RemoteVar::Tie',
    'VERSION_FROM'	=> 'Tie.pm', 
    'PREREQ_PM'		=> {}, 
    ($] >= 5.005 ?    
      (ABSTRACT_FROM => 'Tie.pm', 
       AUTHOR     => 'xern <xern@cpan.org>') : ()),
);

use 5.008006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Net::Netcraft::Query',
    VERSION_FROM      => 'lib/Net/Netcraft/Query.pm',
    PREREQ_PM         => {
		HTTP::Request::Common => 1.26,
		LWP => 5.805
	},
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Net/Netcraft/Query.pm',
       AUTHOR         => 'Matteo Cantoni <matteo.cantoni@nothink.org>') : ()),
);

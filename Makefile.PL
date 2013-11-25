use strict;
use warnings;

use ExtUtils::MakeMaker;
use ExtUtils::MakeMaker::CPANfile;

WriteMakefile(
	NAME                => 'MooseX::Role::Hashable',
	AUTHOR              => q{Aaron Cohen <acohen@shutterstock.com>},
	VERSION_FROM        => 'lib/MooseX/Role/Hashable.pm',
	ABSTRACT            => 'Transform the object into a hash',
);

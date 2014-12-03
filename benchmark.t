#! /usr/bin/env perl

use strict;
use warnings qw(all);

use Benchmark qw{:all};

# run each for at least 5 CPU seconds
my $count = $ARGV[0] || -5;

{
	package Foo::FastV1;
	use Moose;
	with 'MooseX::Role::Hashable';

	has bar1 => (is => 'rw', default => 23);
	has bar2 => (is => 'rw', default => 46);

	__PACKAGE__->meta->make_immutable;
}

{
	package Foo::FastV2::Lazy;
	use Moose;
	with 'MooseX::Role::Hashable';

	has bar1 => (is => 'rw', lazy_build => 1);
	has bar2 => (is => 'rw', default => 46);
	sub _build_bar1 { 23 }

	__PACKAGE__->meta->make_immutable;
}

{
	package Foo::FastV3;
	use Moose;
	with 'MooseX::Role::Hashable' => {exclusions => [qw{bar3 bar4 nonexist}]};

	has bar1 => (is => 'rw', default => 23);
	has bar2 => (is => 'rw', default => 46);
	has bar3 => (is => 'rw', default => 42);
	has bar4 => (is => 'rw');

	__PACKAGE__->meta->make_immutable;
}

{
	package Foo::Slow;
	use Moose;
	with 'MooseX::Role::Hashable';

	has bar1 => (is => 'rw', default => 23);
	has bar2 => (is => 'rw', default => 46);
}

my $results = timethese($count, {
	Fastv1 => sub { Foo::FastV1->new->as_hash },
	Fastv3 => sub { Foo::FastV3->new->as_hash },
	Fastv2Lazy => sub { Foo::FastV2::Lazy->new->as_hash },
	Slow => sub { Foo::Slow->new->as_hash },
});

cmpthese($results);

1;

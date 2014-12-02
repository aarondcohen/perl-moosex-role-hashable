#!/usr/bin/env perl

use strict;
use warnings qw(all);

use FindBin ();
use lib "$FindBin::Bin/../lib/";

use Test::Most tests => 3;

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
	with 'MooseX::Role::Hashable' => {exclude_attr => [qw{bar3 bar4}]};

	has bar1 => (is => 'rw', default => 23);
	has bar2 => (is => 'rw', default => 46);
	has bar3 => (is => 'rw', default => 42);

	__PACKAGE__->meta->make_immutable;
}


{
	package Foo::Slow;
	use Moose;
	with 'MooseX::Role::Hashable';

	has bar1 => (is => 'rw', default => 23);
	has bar2 => (is => 'rw', default => 46);
}

my $foo_fast_v1 = Foo::FastV1->new;
my $foo_fast_v2_lazy = Foo::FastV2::Lazy->new;
my $foo_fast_v3 = Foo::FastV3->new;
my $foo_slow = Foo::Slow->new;

is_deeply $foo_fast_v3->as_hash, $foo_fast_v1->as_hash;
is_deeply $foo_fast_v1->as_hash, $foo_fast_v2_lazy->as_hash;
is_deeply $foo_fast_v2_lazy->as_hash, $foo_slow->as_hash;

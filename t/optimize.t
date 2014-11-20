#!/usr/bin/env perl

use strict;
use warnings qw(all);

use FindBin ();
use lib "$FindBin::Bin/../lib/";

use Test::Most tests => 2;

{
	package Foo::Fast;
	use Moose;
	with 'MooseX::Role::Hashable';

	has bar1 => (is => 'rw', default => 23);
	has bar2 => (is => 'rw', default => 46);

	__PACKAGE__->meta->make_immutable;
}

{
	package Foo::Lazy;
	use Moose;
	with 'MooseX::Role::Hashable';

	has bar1 => (is => 'rw', lazy_build => 1);
	has bar2 => (is => 'rw', default => 46);
	sub _build_bar1 { 23 }

	__PACKAGE__->meta->make_immutable;
}

{
	package Foo::Slow;
	use Moose;
	with 'MooseX::Role::Hashable';

	has bar1 => (is => 'rw', default => 23);
	has bar2 => (is => 'rw', default => 46);
}

my $foo_fast = Foo::Fast->new;
my $foo_lazy = Foo::Lazy->new;
my $foo_slow = Foo::Slow->new;

is_deeply $foo_fast->as_hash, $foo_lazy->as_hash;
is_deeply $foo_lazy->as_hash, $foo_slow->as_hash;

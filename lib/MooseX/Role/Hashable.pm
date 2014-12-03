package MooseX::Role::Hashable;

=head1 NAME

MooseX::Role::Hashable - transform the object into a hash

=cut

use strict;
use warnings;

use List::Util qw{any first};
use MooseX::Role::Parameterized;

use namespace::autoclean;

=head1 VERSION

Version 1.01

=cut

our $VERSION = '1.01';

=head1 SYNOPSIS

This module adds a single method to an object to convert it into a simple hash.
In some ways, this can be seen as the inverse function to I<new>, provided
nothing too crazy is going on during initialization.

Example usage:

	package Foo;
	use Moose;
	with MooseX::Role::Hashable;

	has field1 => (is => 'rw');
	has field2 => (is => 'ro');
	has field3 => (is => 'bare');

	__PACKAGE__->meta->make_immutable;

	package main;

	my $foo = Foo->new(field1 => 'val1', field2 => 'val2', field3 => 'val3');
	$foo->as_hash;
	# => {field1 => 'val1', field2 => 'val2', field3 => 'val3'}

Optionally, you can explcitly remove fields from the hash.
Example usage:
	package Foo;
	use Moose;
	with 'MooseX::Role::Hashable' => {exclusions => [qw{field3 field4}]};

	has field1 => (is => 'rw');
	has field2 => (is => 'ro');
	has field3 => (is => 'bare');
	has field4 => (is => 'rw');

	__PACKAGE__->meta->make_immutable;

	package main;

	my $foo = Foo->new(field1 => 'val1', field2 => 'val2', field3 => 'val3');
	$foo->as_hash;
	# => {field1 => 'val1', field2 => 'val2'}

=cut

my %CLASS_TO_IMPLEMENTATION;

parameter exclusions => (isa => 'ArrayRef', default => sub { [] });

role {
	my $params = shift;
	my %args = @_;

	my $class_meta = $args{consumer};
	#FIXME: There's a bug here when $class_meta is undefined for a Child class
	$CLASS_TO_IMPLEMENTATION{$class_meta->name}{exclusions} = $params->exclusions;

	my $moose_meta = Moose::Meta::Class->meta;
	$moose_meta->make_mutable;
	$moose_meta->add_after_method_modifier('make_immutable', sub {
		my $meta = shift;
		my $class = $meta->name;
		$class->optimize_as_hash
			if $class->can('does')
			&& $class->does(__PACKAGE__);
	});
	$moose_meta->make_immutable;
};

=head1 METHODS

=cut

=head2 as_hash

Transform the object into a hash of attribute-value pairs.  All attributes,
including those without a reader, are extracted.  If a value is a reference,
as_hash will perform a shallow copy.

=cut


my $_as_hash_fast_remove = sub {
	my $self = shift;
	my $exclusions = $CLASS_TO_IMPLEMENTATION{ref $self}{exclusions};

	my %new_hash = %$self;
	delete @new_hash{@$exclusions};

	return \%new_hash;
};

my $_as_hash_fast_fetch = sub {
	my $self = shift;
	my $inclusions = $CLASS_TO_IMPLEMENTATION{ref $self}{inclusions};

	my %new_hash;
	my @missing_names;
	for (@$inclusions) {
		if (exists $self->{$_}) {
			$new_hash{$_} = $self->{$_}
		} else {
			push @missing_names, $_;
		}
	}

	return +{ %new_hash, map { ($_ => $self->meta->find_attribute_by_name($_)->get_value($self)) } @missing_names };
};

my $_as_hash_fast_raw = sub { +{ %{$_[0]} } };

my $_as_hash_safe = sub {
	my $self = shift;
	my $exclusions = $CLASS_TO_IMPLEMENTATION{ref $self}{exclusions};

	my @all_attributes = $self->meta->get_all_attributes;
	my %name_to_attr = map { ($_->name => $_) } @all_attributes;
	delete @name_to_attr{@$exclusions};
	return +{
		map { ($_->name => $_->get_value($self)) }
		values %name_to_attr
	};
};

sub as_hash {
	my $self = shift;

	my $implementation = $CLASS_TO_IMPLEMENTATION{ref $self} || {code => $_as_hash_safe};
	exists $implementation->{code}
		? return $implementation->{code}->($self)
		: return $_as_hash_safe->($self);
}

sub optimize_as_hash {
	my $class = shift;

	my @all_attributes = $class->meta->get_all_attributes;
	my %name_to_attr = map { ($_->name => $_) } @all_attributes;
	my $implementation = $CLASS_TO_IMPLEMENTATION{$class};
	my $exclusions = $implementation->{exclusions};

	delete @name_to_attr{@$exclusions};
	my @all_valid_attr = values %name_to_attr;

	#TODO: should we also check the attributes or is the class enough?
	my $is_inside_out = $class->can('does') && $class->does('MooseX::InsideOut::Role::Meta::Instance');
	my $has_lazy = any { $_->is_lazy } @all_valid_attr;
	my @undefined_attrs = grep { ! ($_->has_default || $_->is_required || ($_->has_builder && ! $_->is_lazy)) } @all_valid_attr;

	if (! $is_inside_out) {
		if (! ($has_lazy || @undefined_attrs) ) {
			$implementation->{code} = (@$exclusions)
				? $_as_hash_fast_remove
				: $_as_hash_fast_raw;
		} elsif (@undefined_attrs) {
			$implementation->{code} = $_as_hash_fast_fetch;
			$implementation->{inclusions} = [keys %name_to_attr];
		} elsif (! @$exclusions) {
			$implementation->{code} = $_as_hash_fast_raw;
		}
	}

	return;
}

=head1 AUTHOR

Aaron Cohen, C<< <aarondcohen at gmail.com> >>

=head1 ACKNOWLEDGEMENTS

This module was made possible by L<Shutterstock|http://www.shutterstock.com/>
(L<@ShutterTech|https://twitter.com/ShutterTech>).  Additional open source
projects from Shutterstock can be found at
L<code.shutterstock.com|http://code.shutterstock.com/>.

=head1 BUGS

Please report any bugs or feature requests to C<bug-MooseX-Role-Hashable at rt.cpan.org>, or through
the web interface at L<https://github.com/aarondcohen/perl-moosex-role-hashable/issues>.  I will
be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::Role::Hashable

You can also look for information at:

=over 4

=item * Official GitHub Repo

L<https://github.com/aarondcohen/perl-moosex-role-hashable>

=item * GitHub's Issue Tracker (report bugs here)

L<https://github.com/aarondcohen/perl-moosex-role-hashable/issues>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-Role-Hashable>

=item * Official CPAN Page

L<http://search.cpan.org/dist/MooseX-Role-Hashable/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Aaron Cohen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of MooseX::Role::Hashable

# NAME

MooseX::Role::Hashable - transform the object into a hash

# VERSION

Version 1.01

# SYNOPSIS

This module adds a single method to an object to convert it into a simple hash.
In some ways, this can be seen as the inverse function to _new_, provided
nothing too crazy is going on during initialization.

Example usage:

        package Foo;
        use Moose;
        use MooseX::Role::Hashable;

        has field1 => (is => 'rw');
        has field2 => (is => 'ro');
        has field3 => (is => 'bare');

        __PACKAGE__->meta->make_immutable;

        package main;

        my $foo = Foo->new(field1 => 'val1', field2 => 'val2', field3 => 'val3');
        $foo->as_hash;
        # => {field1 => 'val1', field2 => 'val2', field3 => 'val3'}

# METHODS

## as\_hash

Transform the object into a hash of attribute-value pairs.  All attributes,
including those without a reader, are extracted.  If a value is a reference,
as\_hash will perform a shallow copy.

# AUTHOR

Aaron Cohen, `<aarondcohen at gmail.com>`

# ACKNOWLEDGEMENTS

This module was made possible by [Shutterstock](http://www.shutterstock.com/)
([@ShutterTech](https://twitter.com/ShutterTech)).  Additional open source
projects from Shutterstock can be found at
[code.shutterstock.com](http://code.shutterstock.com/).

# BUGS

Please report any bugs or feature requests to `bug-MooseX-Role-Hashable at rt.cpan.org`, or through
the web interface at [https://github.com/aarondcohen/perl-moosex-role-hashable/issues](https://github.com/aarondcohen/perl-moosex-role-hashable/issues).  I will
be notified, and then you'll automatically be notified of progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MooseX::Role::Hashable

You can also look for information at:

- Official GitHub Repo

    [https://github.com/aarondcohen/perl-moosex-role-hashable](https://github.com/aarondcohen/perl-moosex-role-hashable)

- GitHub's Issue Tracker (report bugs here)

    [https://github.com/aarondcohen/perl-moosex-role-hashable/issues](https://github.com/aarondcohen/perl-moosex-role-hashable/issues)

- CPAN Ratings

    [http://cpanratings.perl.org/d/MooseX-Role-Hashable](http://cpanratings.perl.org/d/MooseX-Role-Hashable)

- Official CPAN Page

    [http://search.cpan.org/dist/MooseX-Role-Hashable/](http://search.cpan.org/dist/MooseX-Role-Hashable/)

# LICENSE AND COPYRIGHT

Copyright 2013 Aaron Cohen.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

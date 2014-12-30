package MooseX::Trait::Unhashable;

use strict;
use warnings;

use Moose::Role;
use namespace::autoclean;

Moose::Util::meta_attribute_alias('Unhashable');

1;

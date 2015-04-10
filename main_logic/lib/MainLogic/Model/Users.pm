package MainLogic::Model::Users;

use strict;
use warnings;

use List::Util qw(none);
use Common::Defines qw(:all);
use MainLogic::DB::Users qw(:all);

my $__users;

sub instance
{
	my $class = shift;

	return $__users
		if $__users;

	$__users = bless {
	}, $class;

	return $__users;
}

sub add
{
	my ($self, $args) = @_;

	return { error => 'invalid role' }
		if none { $_ == $args->{role} } ROLES_ARRAY();
	return { error => 'incorrect login' }
		if not $args->{login};
	return { error => 'pass_hash not specified' }
		if not $args->{pass_hash};

	return users_add($args);
}

sub delete
{
	my ($self, $args) = @_;

	return { error => 'incorrect login' }
		if not $args->{login};

	return users_delete($args);
}

1;

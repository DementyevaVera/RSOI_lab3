package MainLogic::DB::Users;

use strict;
use warnings;

use Data::Dumper;
use Common::DB qw(:all);
use Common::Defines qw(:all);

use base qw(Exporter);

our @EXPORT_OK = qw(
	users_add
	users_delete
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub users_add
{
	my $args = shift;

	my $role = $args->{role};
	return { error => 'company_id not specified' }
		if $role != ROLE_ID_CUSTOMER() and not $args->{company_id};

	# ignore company_id for customer
	if ($role == ROLE_ID_CUSTOMER()) {
		delete $args->{company_id};
	}

	# insert user
	my $ret = execute_query(qq{
		INSERT INTO $TABLE_NAME_USERS
			(login, pass_hash, role_id, company_id)
		VALUES	(?, ?, ?, ?)
	}, @{$args}{qw(login pass_hash role company_id)});

	return { ok => 'user has beed added' };
}

sub users_delete
{
	my $args = shift;

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_USERS
		WHERE login=?
	}, $args->{login});

	return { ok => 'user has beed deleted' };
}

1;

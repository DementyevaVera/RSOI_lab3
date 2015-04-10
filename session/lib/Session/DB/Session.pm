package Session::DB::Session;

use strict;
use warnings;

use Data::Dumper;
use Common::DB qw(:all);
use Common::Defines qw(:all);

use base qw(Exporter);

our @EXPORT_OK = qw(
	session_new
	session_check
	session_delete
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub session_new
{
	my $args = shift;

	return { error => 'incorrect login specified' }
		if not $args->{login};
	return { error => 'incorrect pass_hash specified' }
		if not $args->{pass_hash};

	my $ret = select_row(qq{
		SELECT 1
		FROM $TABLE_NAME_USERS
		WHERE login=? and pass_hash=?
	}, @{$args}{qw(login pass_hash)});

	return { error => 'invalid login or password' }
		if not $ret;

	$ret = select_row(qq{
		INSERT INTO $TABLE_NAME_SESSIONS
			(id, user_id, token, expiration_date)
		VALUES	(DEFAULT, ?, ?, now() + interval '$args->{expiries_in} second')
		RETURNING id
	}, @{$args}{qw(login token)});

	return { token => $args->{token}, id => $ret->{id} };
}

sub session_delete
{
	my $args = shift;

	return { error => 'incorrect id specified' }
		if not $args->{id};
	return { error => 'incorrect token specified' }
		if not $args->{token};

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_SESSIONS
		WHERE id=? and token=?
	}, @{$args}{qw(id token)});

	return { ok => 'session deleted' };
}

sub session_check
{
	my $args = shift;

	return { error => 'incorrect id specified' }
		if not $args->{id};
	return { error => 'incorrect token specified' }
		if not $args->{token};

	my $ret = select_row(qq{
		SELECT user_id, role_id, company_id
		FROM $TABLE_NAME_SESSIONS
		INNER JOIN $TABLE_NAME_USERS
			ON ${TABLE_NAME_SESSIONS}.user_id = ${TABLE_NAME_USERS}.login
		WHERE id=? and token=? and expiration_date > now()
	}, $args->{id}, $args->{token});

	return { error => 'bad token or session id' }
		if not $ret;

	return $ret;
}

1;

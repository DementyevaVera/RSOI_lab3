package Common::DB;

use strict;
use warnings;

use DBI;
use Carp;
use Data::Dumper;
use Common::Defines qw(:all);

use base qw(Exporter);

our @EXPORT_OK = qw(
	table_exists

	select_row
	select_array
	execute_query

	$TABLE_NAME_JOBS
	$TABLE_NAME_USERS
	$TABLE_NAME_ROLES
	$TABLE_NAME_SESSIONS
	$TABLE_NAME_COMPANIES
	%TABLE_NAME_ROLE_INFO_FOR
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

my $__dbh;

BEGIN {
	$__dbh = DBI->connect(
		'dbi:Pg:dbname=soa',
		'vera', '12345',
		{
			AutoCommit => 1,
			RaiseError => 1
		}
	) or croak 'can\t connect to `rsoi\' database: ' . DBI::errstr();
}

our $TABLE_NAME_JOBS = 'jobs';
our $TABLE_NAME_USERS = 'users';
our $TABLE_NAME_ROLES = 'roles';
our $TABLE_NAME_SESSIONS = 'sessions';
our $TABLE_NAME_COMPANIES = 'companies';
our %TABLE_NAME_ROLE_INFO_FOR = (
	ROLE_ID_MANAGER()	=> 'managers_info',
	ROLE_ID_DIRECTOR()	=> 'directors_info',
);


sub select_row
{
	my ($query, @args) = @_;

	my $sth = $__dbh->prepare($query);
	$sth->execute(@args)
		or croak $__dbh->errstr();

	return $sth->fetchrow_hashref();
}

sub select_array
{
	my ($query, $use_array_of_hashes, @args) = @_;

	my $response_type = $use_array_of_hashes ? { Slice => {} } : undef;
	my $res = $__dbh->selectall_arrayref($query, $response_type, @args)
		or croak $__dbh->errstr();

	return $res;
}

sub execute_query
{
	my ($query, @args) = @_;

	my $ret = $__dbh->do($query, undef, @args)
		or croak $__dbh->errstr();

	return $ret;
}

sub table_exists
{
	my $table = shift;

	return select_row(q{
		SELECT 1
		FROM pg_tables
		WHERE schemaname='public' AND tablename=?
	}, $table);
}

END {
	if ($__dbh) {
		$__dbh->disconnect();
	}
}

1;

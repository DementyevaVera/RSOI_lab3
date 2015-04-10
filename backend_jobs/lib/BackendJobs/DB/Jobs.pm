package BackendJobs::DB::Jobs;

use strict;
use warnings;

use Common::DB qw(:all);

use base qw(Exporter);

our @EXPORT_OK = qw(
	jobs_info
	jobs_total

	jobs_list
	jobs_list_by_company_id

	jobs_add
	jobs_edit
	jobs_delete
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub jobs_info
{
	my $id = shift;

	return { error => 'invalid job id specified' }
		if not $id;

	return select_row(qq{
		SELECT id, company_id, name, salary, requirements
		FROM $TABLE_NAME_JOBS
		WHERE id=?
	}, $id);
}

sub jobs_total
{
	return select_row(qq{
		SELECT COUNT(*) as total
		FROM $TABLE_NAME_JOBS
	});
}

sub jobs_list
{
	my ($limit, $offset) = @_;

	return { error => 'invalid limit or offset' }
		if not (defined $limit and defined $offset);

	return select_array(qq{
		SELECT id, name, salary, company_id
		FROM $TABLE_NAME_JOBS
		ORDER BY id
		LIMIT ?
		OFFSET ?
	}, 'use_hash', $limit, $offset);
}

sub jobs_list_by_company_id
{
	my $id = shift;

	return { error => 'invalid company_id specified' }
		if not $id;

	my $result = select_array(qq{
		SELECT id
		FROM $TABLE_NAME_JOBS
		WHERE company_id=?
	}, undef, $id);
	$result = [ map { $_->[0] } @{$result} ];

	return { jobs => $result };
}

sub jobs_add
{
	my $args = shift;

	return { error => 'company_id not specified' }
		if not $args->{company_id};

	my @args_list = qw(company_id name salary requirements);
	my $ret = execute_query(qq{
		INSERT INTO $TABLE_NAME_JOBS
			(company_id, name, salary, requirements)
		values (?, ?, ?, ?)
	}, @{$args}{@args_list});

	return { ok => 'job has been added' };
}

sub jobs_edit
{
	my $args = shift;

	my $job_id = delete $args->{id};
	return { error => 'job id not specified' }
		if not $job_id;

	$args = { map { $_ => $args->{$_} } qw(id salary name requirements) };

	my @keys = grep { defined $args->{$_} } keys %{$args};
	my @values = @{$args}{@keys};

	my @pairs = map { "$_=?" } @keys;

	my $update_string = join q{, }, @pairs;
	return { ok => 'nothing to update' }
		if not $update_string;

	my $ret = execute_query(qq{
		UPDATE $TABLE_NAME_JOBS
		SET $update_string
		WHERE id=?
	}, @values, $job_id);

	return { ok => 'job has been changed' };
}

sub jobs_delete
{
	my $id = shift;

	return { error => 'job id not specified' }
		if not $id;

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_JOBS
		WHERE id=?
	}, $id);

	return { ok => 'job has been deleted' };
}

1;

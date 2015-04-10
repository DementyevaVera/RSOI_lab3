package BackendJobs::Model::Jobs;

use strict;
use warnings;

use BackendJobs::DB::Jobs qw(:all);

my $__jobs;

sub instance
{
	my $class = shift;

	return $__jobs
		if $__jobs;

	$__jobs = bless {
	}, $class;

	return $__jobs;
}

sub info
{
	my ($self, $id) = @_;

	return jobs_info($id);
}

sub list
{
	my ($self, $limit, $offset, $company_id) = @_;

	return jobs_list_by_company_id($company_id)
		if $company_id;

	return jobs_list($limit, $offset);
}

sub count
{
	my ($self) = @_;

	return jobs_total();
}

sub add
{
	my ($self, $args) = @_;

	return jobs_add($args);
}

sub edit
{
	my ($self, $args) = @_;

	return jobs_edit($args);
}

sub delete
{
	my ($self, $id) = @_;

	return jobs_delete($id);
}

1;

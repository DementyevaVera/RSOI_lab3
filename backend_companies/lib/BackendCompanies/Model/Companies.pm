package BackendCompanies::Model::Companies;

use strict;
use warnings;

use BackendCompanies::DB::Companies qw(:all);

my $__firms;

sub instance
{
	my $class = shift;

	return $__firms
		if $__firms;

	$__firms = bless {
	}, $class;

	return $__firms;
}

sub batch_list
{
	my ($self, $ids) = @_;

	return companies_batch_list($ids);
}

sub info
{
	my ($self, $id) = @_;

	return { error => 'company id not specified' }
		if not $id;

	return companies_info($id);
}

sub list
{
	my ($self, $limit, $offset) = @_;

	return { error => 'invalid offset or limit not specified' }
		if not (defined $limit and defined $offset);

	return companies_list($limit, $offset);
}

sub count
{
	my $self = shift;

	return companies_count();
}

sub add
{
	my ($self, $args) = @_;

	return companies_add($args);
}

sub edit
{
	my ($self, $args) = @_;

	return companies_edit($args);
}

sub delete
{
	my ($self, $id) = @_;

	return companies_delete($id);
}

1;

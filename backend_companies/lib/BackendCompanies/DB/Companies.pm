package BackendCompanies::DB::Companies;

use strict;
use warnings;

use Common::DB qw(:all);

use base qw(Exporter);

our @EXPORT_OK = qw(
	companies_info
	companies_list
	companies_count

	companies_add
	companies_edit
	companies_delete
	companies_batch_list
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub companies_batch_list
{
	my $ids = shift;
	my $ids_join = join q{,}, @{$ids};

	return select_array(qq{
		SELECT id, name, description
		FROM $TABLE_NAME_COMPANIES
		WHERE id IN ($ids_join)
	}, 'use_hash');
}

sub companies_info
{
	my $id = shift;

	return select_row(qq{
		SELECT id, name, description
		FROM $TABLE_NAME_COMPANIES
		WHERE id=?
	}, $id);
}

sub companies_count
{
	return select_row(qq{
		SELECT COUNT(*) as total
		FROM $TABLE_NAME_COMPANIES
	});
}

sub companies_list
{
	my ($limit, $offset) = @_;

	return select_array(qq{
		SELECT id, name
		FROM $TABLE_NAME_COMPANIES
		ORDER BY id
		LIMIT ?
		OFFSET ?
	}, 'use_hash', $limit, $offset);
}

sub companies_add
{
	my $args = shift;

	my @args_list = qw(name description);
	my $ret = select_row(qq{
		INSERT INTO $TABLE_NAME_COMPANIES
			(id, name, description)
		values (DEFAULT, ?, ?)
		RETURNING id
	}, @{$args}{@args_list});

	return { ok => 'company has been added', company_id => $ret->{id} };
}

sub companies_edit
{
	my $args = shift;

	my $company_id = delete $args->{id};
	return { error => 'company id not specified' }
		if not $company_id;

	$args = { map { $_ => $args->{$_} } qw(name description) };
	my @keys = grep { defined $args->{$_} } keys %{$args};
	my @values = @{$args}{@keys};

	my @pairs = map { "$_=?" } @keys;

	my $update_string = join q{, }, @pairs;
	return { ok => 'nothing to update' }
		if not $update_string;

	my $ret = execute_query(qq{
		UPDATE $TABLE_NAME_COMPANIES
		SET $update_string
		WHERE id=?
	}, @values, $company_id);

	return { ok => 'company has been changed' };
}

sub companies_delete
{
	my $id = shift;

	return { error => 'company id not specified' }
		if not $id;

	my $ret = execute_query(qq{
		DELETE FROM $TABLE_NAME_COMPANIES
		WHERE id=?
	}, $id);

	return { ok => 'company has been deleted' };
}

1;

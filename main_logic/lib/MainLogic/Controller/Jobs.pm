package MainLogic::Controller::Jobs;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Common::RequestSender qw(:all);

sub count
{
	my $self = shift;

	my $resp = send_request({
		method => 'get',
		url => 'http://localhost/jobs/count',
		port => $self->service_jobs_port() || 0,
	});

	$self->app->log->debug('[JOBS] count, resp: ', Dumper $resp);

	return $self->render(json => $resp);
}

sub list
{
	my $self = shift;

	my $user = $self->stash('user');
	my $company_id = $self->param('writable') ? $user->{'company_id'} : q{};
	my $resp = send_request({
		method => 'get',
		url => 'http://localhost/jobs',
		port => $self->service_jobs_port() || 0,
		args => {
			limit		=> $self->param('limit'),
			offset		=> $self->param('offset'),
			company_id	=> $company_id,
		},
	});


	my @ids = map {
		$_->{company_id}
	} @{$resp};

	my $joined_ids = join q{,}, @ids;
	my $companies_resp = send_request({
		method => 'get',
		url => 'http://localhost/companies/batch',
		port => $self->service_companies_port() || 0,
		args => {
			ids => $joined_ids,
		}
	});

	my %companies_info = map {
		$_->{id} => $_
	} @{$companies_resp};

	my $final_resp = [];
	foreach my $job (@{$resp}) {
		$job->{company_info} = $companies_info{$job->{company_id}};
		push @{$final_resp}, $job;
	}

	$self->app->log->debug('[JOBS] list, resp ', Dumper $resp);

	return $self->render(json => $final_resp);
}

sub info
{
	my $self = shift;

	my $id = $self->param('job_id');
	my $resp = send_request({
		method => 'get',
		url => "http://localhost/jobs/$id",
		port => $self->service_jobs_port() || 0,
	});

	$self->app->log->debug('[JOBS] count, info: ', Dumper $resp);

	return $self->render(json => $resp);
}

# company_id, name, salary, requirements
sub add
{
	my $self = shift;

	my $args = $self->req->json();
	my $user = $self->stash('user');
	$args->{company_id} = $user->{company_id};

	my $resp = send_request({
		method => 'post',
		url => 'http://localhost/jobs/',
		port => $self->service_jobs_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[JOBS] count, add: ', Dumper $resp);

	return $self->render(json => $resp);
}

# id, name, salary, requirements
sub update
{
	my $self = shift;

	my $args = $self->req->json();
	$args->{id} = $args->{job_id};

	my $resp = send_request({
		method => 'put',
		url => 'http://localhost/jobs/',
		port => $self->service_jobs_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[JOBS] count, update: ', Dumper $resp);

	return $self->render(json => $resp);
}

# id
sub delete
{
	my $self = shift;

	my $args = $self->req->json();
	$args->{id} = $args->{job_id} || q{};

	my $resp = send_request({
		method => 'delete',
		url => 'http://localhost/jobs/',
		port => $self->service_jobs_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[JOBS] count, delete: ', Dumper $resp);

	return $self->render(json => $resp);
}

1;

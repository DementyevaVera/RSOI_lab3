package MainLogic::Controller::Companies;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Common::Defines qw(:all);
use Common::RequestSender qw(:all);

sub count
{
	my $self = shift;

	my $resp = send_request({
		method	=> 'get',
		url	=> 'http://localhost/companies/count',
		port	=> $self->service_companies_port() || q{},
	});

	$self->app->log->debug('[COMPANIES] count, resp: ', Dumper $resp);

	return $self->render(json => $resp);
}

sub list
{
	my $self = shift;

	my $resp = send_request({
			method => 'get',
			url => 'http://localhost/companies',
			port => $self->service_companies_port() || 0,
			args => {
				limit  => $self->param('limit'),
				offset => $self->param('offset'),
			}
	});

	$self->app->log->debug('[COMPANIES] list, resp: ', Dumper $resp);

	return $self->render(json => $resp);
}

sub info
{
	my $self = shift;

	my $id = $self->param('company_id');
	my $resp_firm_info = send_request({
		method => 'get',
		url => "http://localhost/companies/$id",
		port => $self->service_companies_port() || 0,
	});

	if ($self->param('detail')) {
		my $resp = send_request({
			method => 'get',
			url => 'http://localhost/jobs',
			port => $self->service_jobs_port() || 0,
			args => {
				company_id => $id,
			},
		});

		$resp_firm_info->{jobs} = $resp->{jobs};
	}

	$self->app->log->debug('[COMPANIES] info, resp: ', Dumper $resp_firm_info);

	return $self->render(json => $resp_firm_info);
}

# name, description + login, pass_hash
sub add
{
	my $self = shift;

	my $args = $self->req->json();
	my $resp = send_request({
		method => 'post',
		url => 'http://localhost/companies/',
		port => $self->service_companies_port() || 0,
		args => $args,
	});

	$args->{role} = ROLE_ID_DIRECTOR();
	$args->{company_id} = $resp->{company_id};

	my $user_resp = eval {
		$self->users_helper->add($args)
	} || {
		error => "internal error",
		error_description => $@,
	};

	$self->app->log->debug('[COMPANIES] add');

	return $self->render(
		json => {
			company_resp => $resp,
			user_resp => $user_resp,
		}
	);
}

# company_id, name, description
sub update
{
	my $self = shift;

	my $args = $self->req->json();
	my $user = $self->stash('user');

	$args->{id} = $user->{'company_id'};

	my $resp = send_request({
		method => 'put',
		url => 'http://localhost/companies/',
		port => $self->service_companies_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[COMPANIES] update', Dumper $resp);

	return $self->render(json => $resp);
}

# id
sub delete
{
	my $self = shift;

	my $args = $self->req->json();
	$args->{id} = $args->{company_id} || q{};

	my $resp = send_request({
		method => 'delete',
		url => 'http://localhost/companies/',
		port => $self->service_companies_port() || 0,
		args => $args,
	});

	$self->app->log->debug('[COMPANIES] delete', Dumper $resp);

	return $self->render(json => $resp);
}

1;

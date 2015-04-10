package Front::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use Common::RequestSender qw(:all);

my $PORT_LOGIC_SERVICE = $ENV{SERVICE_LOGIC_PORT};

sub index
{
	my $self = shift;

	$self->render();
}

# /users
sub users
{
	my $self = shift;

	my $role	= $self->param('role')		|| '';
	my $pass	= $self->param('pass')		|| '';
	my $login	= $self->param('login')		|| '';
	my $company_id	= $self->param('company_id')	|| '';

	return $self->render()
		if not ($login and $pass and $role);

	my $pass_hash = md5_hex($pass);
	my $session = $self->session('session_info') || {};

	my $resp = send_request({
		method	=> 'post',
		url	=> 'http://localhost/users',
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			role		=> $role,
			login		=> $login,
			pass_hash	=> $pass_hash,
			company_id	=> $company_id,
		}
	});

	$self->app->log->debug('[FRONT], users, resp: ', Dumper $resp);

	return $self->redirect_to('index')
		if exists $resp->{ok};

	return $self->render();
}

sub __new_company
{
	my $self = shift;

	my $name	= $self->param('name')		|| q{};
	my $pass	= $self->param('pass')		|| q{};
	my $login	= $self->param('login')		|| q{};
	my $description	= $self->param('description')	|| q{};

	my $pass_hash = md5_hex($pass);

	return $self->redirect_to('companies')
		if not ($login and $pass);

	my $resp = send_request({
		method	=> 'post',
		url	=> 'http://localhost/companies',
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			name		=> $name,
			login		=> $login,
			pass_hash	=> $pass_hash,
			description	=> $description,
		}
	});

	$self->app->log->debug('[FRONT], new_company, resp: ', Dumper $resp);

	return $self->redirect_to('index')
		if exists $resp->{user_resp}{ok}
		   and exists $resp->{company_resp}{ok};

	return $self->redirect_to('companies');
}

sub __update_company
{
	my $self = shift;

	my $id		= $self->param('id')			|| q{};
	my $name	= $self->param('name')			|| q{};
	my $description	= $self->param('description')		|| q{};
	my $session	= $self->session('session_info')	|| {};

	my $resp = send_request({
		method	=> 'put',
		url	=> "http://localhost/companies/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			name		=> $name,
			company_id	=> $id,
			description	=> $description,
		}
	});

	$self->app->log->debug('[FRONT], update_company, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __delete_company
{
	my $self = shift;

	my $id		= $self->param('id')			|| q{};
	my $session	= $self->session('session_info')	|| {};

	my $resp = send_request({
		method	=> 'delete',
		url	=> "http://localhost/companies/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			company_id	=> $id,
		}
	});

	$self->app->log->debug('[FRONT], delete_company, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __select_company
{
	my $self = shift;

	my $page	= $self->param('page')		|| 1;
	my $company_id	= $self->param('company_id')	|| q{};

	my $limit	= 10;
	my $offset	= ($page - 1) * $limit;

	my $resp = send_request({
		method	=> 'get',
		url	=> "http://localhost/companies/$company_id",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			limit	=> $limit,
			offset	=> $offset,
			detail	=> 1,
		}
	});

	$self->app->log->debug('[FRONT], select_company, resp: ', Dumper $resp);

	if ($company_id) {
		$self->stash($resp);
		return $self->render(template => 'main/companies.main');
	}

	return $self->render(template => 'main/companies.list',
			     prev => $page - 1,
			     next => $page + 1,
			     list_ref => $resp,
	);
}

# /companies
sub companies
{
	my $self = shift;

	my $method = $self->param('button') || q{};

	if ($method eq 'Register') {
		return __new_company($self);
	} elsif ($method eq 'Update') {
		return __update_company($self);
	} elsif ($method eq 'Delete') {
		return __delete_company($self);
	} elsif ($method eq 'Select') {
		return __select_company($self);
	}

	$self->render(text => 'unknown method specified');
}

sub __new_job
{
	my $self = shift;

	# name, salary, reqs
	my $session = $self->session('session_info') || {};

	my $name		= $self->param('name')		|| q{};
	my $salary		= $self->param('salary')	|| q{};
	my $requirements	= $self->param('requirements')	|| q{};

	my $resp = send_request({
		method	=> 'post',
		url	=> "http://localhost/jobs/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			name		=> $name,
			salary		=> $salary,
			requirements	=> $requirements,
		}
	});

	$self->app->log->debug('[FRONT], new_job, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __update_job
{
	my $self = shift;

	my $id			= $self->param('id')		|| q{};
	my $name		= $self->param('name')		|| q{};
	my $salary		= $self->param('salary')	|| q{};
	my $company_id		= $self->param('company_id')	|| q{};
	my $requirements	= $self->param('requirements')	|| q{};

	my $session = $self->session('session_info') || {};

	my $resp = send_request({
		method	=> 'put',
		url	=> "http://localhost/jobs/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			name		=> $name,
			company_id	=> $company_id,
			job_id		=> $id,
			salary		=> $salary,
			requirements	=> $requirements,
		}
	});

	$self->app->log->debug('[FRONT], update_job, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __delete_job
{
	my $self = shift;

	my $id			= $self->param('id')			|| q{};
	my $company_id		= $self->param('company_id')		|| q{};
	my $session		= $self->session('session_info')	|| {};

	my $resp = send_request({
		method	=> 'delete',
		url	=> "http://localhost/jobs/",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			id		=> $session->{id},
			token		=> $session->{token},
			job_id		=> $id,
			company_id	=> $company_id,
		}
	});

	$self->app->log->debug('[FRONT], delete_job, resp: ', Dumper $resp);

	$self->render(json => $resp);
}

sub __select_job
{
	my $self = shift;

	my $page	= $self->param('page')		|| 1;
	my $job_id	= $self->param('job_id')	|| q{};

	my $limit	= 10;
	my $offset	= ($page - 1) * $limit;

	my $session = $self->session('session_info') || {};

	# creating new job
	if ($self->param('create')) {
		$self->stash({
			id		=> 'new job',
			name		=> '',
			salary		=> '',
			company_id	=> 'current company_id',
			requirements	=> '',
		});

		return $self->render(template => 'main/jobs.main')
	}

	my $resp = send_request({
		method	=> 'get',
		url	=> "http://localhost/jobs/$job_id",
		port	=> $PORT_LOGIC_SERVICE,
		args	=> {
			limit		=> $limit,
			offset		=> $offset,
			writable	=> $self->param('writable') || 0,
			id		=> $session->{id},
			token		=> $session->{token},
		}
	});

	$self->app->log->debug('[FRONT], select_job, resp: ', Dumper $resp);

	return $self->render(text => 'access denied')
		if ref $resp eq 'HASH' and exists $resp->{error};

	if ($job_id) {
		$self->stash($resp);
		return $self->render(template => 'main/jobs.main');
	}

	return $self->render(template => 'main/jobs.list',
			     prev => $page - 1,
			     next => $page + 1,
			     list_ref => $resp,
			     writable => $self->param('writable') || 0,
	);
}

# /jobs
sub jobs
{
	my $self = shift;

	my $method = $self->param('button') || q{};

	if ($method eq 'Register') { # registrations
		return __new_job($self);
	} elsif ($method eq 'Update') { # update
		return __update_job($self);
	} elsif ($method eq 'Delete') { # delete
		return __delete_job($self);
	} elsif ($method eq 'Select') { # select
		return __select_job($self);
	}

	$self->render(text => 'unknown method specified');
}

sub user_info
{
	my $self = shift;

	my $session = $self->session('session_info');
	$self->app->log->debug('[FRONT] user_info, session:', Dumper $session);

	my $resp = send_request({
		method => 'get',
		url => 'http://localhost/me',
		port => $PORT_LOGIC_SERVICE,
		args => $session,
	});

	$self->app->log->debug('[FRONT] user_info, resp:', Dumper $resp);

	$self->render(template => 'main/user', user_info => $resp);
}

sub login
{
	my $self = shift;

	my $login = $self->param('login') || '';
	my $pass  = $self->param('pass')  || '';

	return $self->render()
		unless $login or $pass;

	my $pass_hash = md5_hex($pass);

	my $resp = send_request({
		method => 'post',
		url => 'http://localhost/sessions',
		port => $PORT_LOGIC_SERVICE,
		args => {
			login => $login,
			pass_hash => $pass_hash,
		}
	});

	$self->app->log->debug('[FRONT] login, resp: ', Dumper $resp);

	if ($resp and $resp->{id}) {
		$self->session(session_info => $resp);
		return $self->redirect_to('index');
	}

	$self->redirect_to('login');
}

sub logout
{
	my $self = shift;

	my $session = $self->session('session_info');
	return $self->redirect_to('index')
		if not $session;

	my $resp = send_request({
		method => 'delete',
		url => 'http://localhost/sessions',
		port => $PORT_LOGIC_SERVICE,
		args => $session,
	});

	$self->app->log->debug('[FRONT] logout, resp: ', Dumper $resp);

	$self->session(expires => 1);
	$self->redirect_to('index');
}

sub dispatch_request
{
	my $self = shift;

	$self->render(json => 'not implemented yet');
}

1;

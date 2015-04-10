package BackendJobs::Controller::Jobs;
use Mojo::Base 'Mojolicious::Controller';

sub info
{
	my $self = shift;
	my $job_id = $self->param('id');

	my $resp = eval {
		$self->jobs_helper->info($job_id)
	} || {
		error => "can't get job info for: $job_id",
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub list
{
	my $self = shift;

	my $limit	= $self->param('limit');
	my $offset	= $self->param('offset');
	my $company_id	= $self->param('company_id');

	print "limit: $limit, offset: $offset, company_id: $company_id\n";

	my $resp = eval {
		$self->jobs_helper->list($limit, $offset, $company_id)
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub count
{
	my $self = shift;

	my $resp = eval {
		$self->jobs_helper->count()
	} || {
		error => 'server_error',
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub add
{
	my $self = shift;

	# name, salary, company_id, requirements
	my $args = $self->req->json();

	my $ret = eval {
		$self->jobs_helper->add($args)
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

sub edit
{
	my $self = shift;

	# id, name, salary, requirements
	my $args = $self->req->json();

	my $ret = eval {
		$self->jobs_helper->edit($args)
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

sub delete
{
	my $self = shift;

	# id
	my $args = $self->req->json();

	my $ret = eval {
		$self->jobs_helper->delete($args->{id})
	} || {
		error => 'server_error',
		erorr_description => $@,
	};

	$self->render(json => $ret);
}

1;

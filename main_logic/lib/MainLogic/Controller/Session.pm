package MainLogic::Controller::Session;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

use Common::RequestSender qw(:all);

# login, pass_hash
sub add
{
	my $self = shift;

	my $resp = send_request({
		method => 'post',
		url => 'http://localhost/sessions',
		port => $self->service_session_port() || 0,
		args => $self->req->json() || {},
	});

	$self->app->log->debug('LOGIC (session) new, resp: ', Dumper $resp);

	return $self->render(json => $resp);
}

# id, token
sub delete
{
	my $self = shift;

	my $resp = send_request({
		method => 'delete',
		url => 'http://localhost/sessions',
		port => $self->service_session_port() || 0,
		args => $self->req->json() || {},
	});

	$self->app->log->debug('LOGIC (session) delete, resp: ', Dumper $resp);

	return $self->render(json => $resp);
}

1;

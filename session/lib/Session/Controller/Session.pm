package Session::Controller::Session;
use Mojo::Base 'Mojolicious::Controller';

use Common::Defines qw(:all);

sub create
{
	my $self = shift;

	# login, pass_hash
	my $args = $self->req->json();

	my $resp = eval {
		$self->session_helper->new($args)
	} || {
		error => "internal error",
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub delete
{
	my $self = shift;

	# id, token
	my $args = $self->req->json();

	my $resp = eval {
		$self->session_helper->delete($args)
	} || {
		error => "internal error",
		error_description => $@,
	};

	$self->render(json => $resp);
}

sub check
{
	my $self = shift;

	my $args = {
		id	=> $self->param('id')		|| '',
		token	=> $self->param('token')	|| '',
	};

	my $resp = eval {
		$self->session_helper->check_token($args)
	} || {
		error => "internal error",
		error_description => $@,
	};

	$self->render(json => $resp);
}

1;

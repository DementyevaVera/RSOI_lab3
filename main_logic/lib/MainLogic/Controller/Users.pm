package MainLogic::Controller::Users;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub user_info
{
	my $self = shift;

	my $user = $self->stash('user');
	$self->app->log->debug('[LOGIC] (users) user_info, resp: ', Dumper $user);

	$self->render(json => $user);
}

sub add_user
{
	my $self = shift;

	# role, login, pass_hash, company_id
	my $args = $self->req->json() || {};

	foreach (values %{$args}) {
		s/^\s+|\s+$//g;
	}

	my $resp = eval {
		$self->users_helper->add($args)
	} || {
		error => "internal error",
		error_description => $@,
	};

	$self->app->log->debug('[LOGIC] (users) user_info, add: ', Dumper $resp);

	$self->render(json => $resp);
}

sub del_user
{
	my $self = shift;

	# login
	my $args = $self->req->json() || {};

	my $resp = eval {
		$self->users_helper->delete($args)
	} || {
		error => "internal error",
		error_description => $@,
	};

	$self->app->log->debug('[LOGIC] (users) user_info, delete: ', Dumper $resp);

	$self->render(json => $resp);
}

1;

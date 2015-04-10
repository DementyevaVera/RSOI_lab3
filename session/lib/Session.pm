package Session;
use Mojo::Base 'Mojolicious';

use Session::Model::Session;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');
	$self->helper(session_helper => sub { Session::Model::Session->instance() });

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/sessions')->to('session#check');
	$r->post('/sessions')->to('session#create');
	$r->delete('/sessions')->to('session#delete');

	$r->any('/*whatever' => {whatever => ''} => sub {
		my $c = shift;
		my $whatever = $c->param('whatever');
		$c->render(
			json => {
				error => "/$whatever did not match.",
			},
			status => 404,
		);
	});
}

1;

package BackendJobs;
use Mojo::Base 'Mojolicious';

use BackendJobs::Model::Jobs;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');
	$self->helper(jobs_helper => sub { BackendJobs::Model::Jobs->instance() });

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/jobs/count')->to('jobs#count');

	$r->get('/jobs')->to('jobs#list');
	$r->get('/jobs/:id')->to('jobs#info');

	$r->post('/jobs')->to('jobs#add');

	$r->put('/jobs/')->to('jobs#edit');

	$r->delete('/jobs/')->to('jobs#delete');

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

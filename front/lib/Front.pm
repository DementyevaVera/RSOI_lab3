package Front;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/')->to('main#index')->name('index');

	$r->get('/login')->to(template => 'main/login')->name('login');
	$r->post('/login')->to('main#login');

	$r->any('/logout')->to('main#logout');

	$r->get('/me')->to('main#user_info');

	$r->get('/users')->to(template => 'main/users');
	$r->post('/users')->to('main#users');

	$r->get('/companies_form')->to(template => 'main/companies.new')->name('companies');
	$r->any('/companies')->to('main#companies');

	$r->get('/jobs_form')->to(template => 'main/jobs.new')->name('jobs');
	$r->any('/jobs')->to('main#jobs');

	$r->any('/*whatever' => {whatever => ''} => sub {
		my $c = shift;
		my $whatever = $c->param('whatever');
		$c->render(
			text => "error: `/$whatever' not found",
			status => 404,
		);
	});
}

1;

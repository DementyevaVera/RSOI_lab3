package BackendCompanies;
use Mojo::Base 'Mojolicious';

use BackendCompanies::Model::Companies;

# This method will run once at server start
sub startup {
	my $self = shift;

	# Documentation browser under "/perldoc"
	$self->plugin('PODRenderer');
	$self->helper(companies_helper => sub { BackendCompanies::Model::Companies->instance() });

	# Router
	my $r = $self->routes;

	# Normal route to controller
	$r->get('/companies/count')->to('companies#companies_count');

	$r->get('/companies/')->to('companies#companies_list');
	$r->get('/companies/batch')->to('companies#companies_batch_list');
	$r->get('/companies/:id')->to('companies#company_info');

	$r->post('/companies')->to('companies#add');

	$r->put('/companies/')->to('companies#edit');

	$r->delete('/companies/')->to('companies#delete');

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

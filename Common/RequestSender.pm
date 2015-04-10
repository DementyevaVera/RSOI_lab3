package Common::RequestSender;

use Carp qw(croak);
use Mojo::UserAgent;
use Common::Defines qw(:all);

use strict;
use warnings;

use base qw(Exporter);

our @EXPORT_OK = qw(
	send_request
);

our %EXPORT_TAGS = (
	all => [@EXPORT_OK],
);

sub send_request
{
	my $args = shift;

	my $method = $args->{method};
	croak 'method not specified'
		if not $method;
	croak 'url not specified'
		if not $args->{url};

	my $url = Mojo::URL->new($args->{url});
	if ($args->{port}) {
		$url->port($args->{port});
	}
	if ($args->{method} eq 'get' and $args->{args}) {
		$url->query(%{$args->{args}});
	}

	my $ua = Mojo::UserAgent->new();

	# use this check, to avoid call of perl parser in runtime
	return $ua->get($url)->res->json()
		if $method eq 'get';
	return $ua->post($url => json => $args->{args})->res->json()
		if $method eq 'post';
	return $ua->put($url => json => $args->{args})->res->json()
		if $method eq 'put';
	return $ua->delete($url => json => $args->{args})->res->json()
		if $method eq 'delete';

	croak "unknown method specified: $method";
}

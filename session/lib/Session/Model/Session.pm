package Session::Model::Session;

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Session::DB::Session qw(:all);

sub TOKEN_LENGTH()		{ 30 }
sub SESSION_EXPIRATION_PERIOD()	{ 300 }

my $__session;

sub instance
{
	my $class = shift;

	return $__session
		if $__session;

	$__session = bless {
	}, $class;

	return $__session;
}

sub __generate_random_string
{
	my ($self, $need_length, @args) = @_;

	return substr(md5_hex(@args, scalar localtime), 0, $need_length);
}

sub new
{
	my ($self, $args) = @_;

	$args->{token} = $self->__generate_random_string(TOKEN_LENGTH(), values %{$args});
	$args->{expiries_in} = SESSION_EXPIRATION_PERIOD();

	return session_new($args);
}

sub delete
{
	my ($self, $args) = @_;

	return session_delete($args);
}

sub check_token
{
	my ($self, $args) = @_;

	return session_check($args);
}

1;

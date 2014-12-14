package Map::Tube::Graph;

# Pragmas.
use strict;
use warnings;

# Modules.
use Class::Utils qw(set_params);
use Error::Pure qw(err);
use Graph;
use List::MoreUtils qw(none);
use Readonly;
use Scalar::Util qw(blessed);

# Constants.
Readonly::Array our @OUTPUTS => qw(text png);

# Version.
our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Graph object.
	$self->{'graph'} = undef;

	# Map::Tube object.
	$self->{'tube'} = undef;

	# Process params.
	set_params($self, @params);

	# Check Map::Tube object.
	if (! defined $self->{'tube'}) {
		err "Parameter 'tube' is required.";
	}
	if (! blessed($self->{'tube'})
		|| ! $self->{'tube'}->does('Map::Tube')) {

		err "Parameter 'tube' must be 'Map::Tube' object.";
	}

	# Graph object.
	if (! defined $self->{'graph'}) {
		$self->{'graph'} = Graph->new;
	}

	# Object.
	return $self;
}

# Get graph.
sub graph {
	my $self = shift;
	foreach my $node (values %{$self->{'tube'}->nodes}) {
		$self->{'graph'}->add_vertex($node->id);
	}
	my @processed;
	foreach my $node (values %{$self->{'tube'}->nodes}) {
		foreach my $link (split m/,/ms, $node->link) {
			if (none {
				($_->[0] eq $node->id && $_->[1] eq $link) 
				|| 
				($_->[0] eq $link && $_->[1] eq $node->id)
				} @processed) {

				$self->{'graph'}->add_edge($node->id, $link);
				push @processed, [$node->id, $link];
			}
		}
	}
	return $self->{'graph'};
}

1;

__END__

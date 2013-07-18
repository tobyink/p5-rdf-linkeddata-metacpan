use v5.14;

package RDF::LinkedData::MetaCPAN::Release 0.001 {
	our $AUTHORITY = 'cpan:TOBYINK';
	
	use Moose;
	use Function::Parameters ':strict';
	use RDF::LinkedData::MetaCPAN::Types -types;
	use RDF::TrineX::Functions
		statement => { -as => 'st' },
		qw/ iri literal blank curie /;
	use namespace::autoclean;
	
	with qw(
		RDF::LinkedData::MetaCPAN::Role::Resource
		RDF::LinkedData::MetaCPAN::Role::UsesMetaCPAN
	);
	
	has author => (
		is        => 'ro',
		isa       => CpanId,
		coerce    => !!1,
		required  => !!1,
	);
	
	has distribution => (
		is        => 'ro',
		isa       => DistName,
		required  => !!1,
	);
	
	has version => (
		is        => 'ro',
		isa       => VersionStr,
		required  => !!1,
	);
	
	has abstract => (
		is        => 'ro',
		isa       => Str,
		predicate => 'has_abstract',
	);
	
	has status => (
		is        => 'ro',
		isa       => Str,
		predicate => 'has_status',
	);
	
	has date => (
		is        => 'ro',
		isa       => Str,
		predicate => 'has_date',
	);
	
	has identifier => (
		is        => 'ro',
		isa       => Str,
		lazy      => !!1,
		builder   => '_build_identifier',
	);
	
	method _build_identifier ()
	{
		sprintf '%s/%s-%s', $self->author, $self->distribution, $self->version;
	}
	
	method uri ()
	{
		sprintf 'http://purl.org/NET/cpan-uri/release/%s', $self->identifier;
	}
	
	method descriptor_uri ()
	{
		sprintf 'http://ontologi.es/cpan-data/release/%s', $self->identifier;
	}
	
	method base_statements ()
	{
		return (
			st( iri($self->uri), curie('dc:identifier'), literal($self->identifier) ),
		);
	}
}

1;

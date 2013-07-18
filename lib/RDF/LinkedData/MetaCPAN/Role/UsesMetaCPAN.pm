use v5.14;

package RDF::LinkedData::MetaCPAN::Role::UsesMetaCPAN 0.001 {
	our $AUTHORITY = 'cpan:TOBYINK';
	
	use Moose::Role;
	use Function::Parameters ':strict';
	use RDF::LinkedData::MetaCPAN::Types -types;
	use namespace::autoclean;
	
	has metacpan => (
		is        => 'ro',
		isa       => InstanceOf['MetaCPAN::API'],
		builder   => '_build_metacpan',
	);
	
	method _build_metacpan ()
	{
		require MetaCPAN::API;
		return 'MetaCPAN::API'->new;
	}
}

1;

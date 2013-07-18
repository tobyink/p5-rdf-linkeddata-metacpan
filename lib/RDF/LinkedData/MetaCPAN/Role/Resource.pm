use v5.14;

package RDF::LinkedData::MetaCPAN::Role::Resource 0.001 {
	our $AUTHORITY = 'cpan:TOBYINK';
	
	use Moose::Role;
	use Function::Parameters ':strict';
	use RDF::TrineX::Functions
		statement => { -as => 'st' },
		qw/ iri literal blank curie /,
		qw/ parse serialize /;
	use RDF::TrineX::Serializer::MockTurtleSoup ();
	use RDF::LinkedData::MetaCPAN::Types -types;
	use namespace::autoclean;
	
	requires 'uri';
	requires 'descriptor_uri';
	requires 'base_statements';
	
	method additional_statements ()
	{
		return;
	}
	
	method all_statements ()
	{
		return (
			$self->base_statements,
			$self->additional_statements,
		);
	}
	
	method dump_rdf ((Object) $serializer = 'RDF::TrineX::Serializer::MockTurtleSoup'->new)
	{
		my $model = parse;
		$model->add_statement($_) for $self->all_statements;
		return serialize($model, using => $serializer);
	}
	
	around base_statements => fun ($orig, $self)
	{
		return (
			$self->$orig,
			st( iri($self->uri),            curie('foaf:isPrimaryTopicOf'), iri($self->descriptor_uri) ),
			st( iri($self->descriptor_uri), curie('rdf:type'),              curie('foaf:Document') ),
			st( iri($self->descriptor_uri), curie('foaf:primaryTopic'),     iri($self->uri) ),
		);
	};
}

1;

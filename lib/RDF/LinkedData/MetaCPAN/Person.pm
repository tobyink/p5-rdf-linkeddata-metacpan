use v5.14;

# Stolen from metacpan-web/root/preprocess.html
my %SERVICES = (
	bitbucket => { name => 'Bitbucket', url => 'http://bitbucket.org/%s'},
	coderwall => { name => 'Coderwall', url => 'http://www.coderwall.com/%s'},
	couchsurfing => { name => 'Couch Surfing', url => 'http://www.couchsurfing.org/people/%s/'},
	delicious => { name => 'Delicious', url => 'http://www.delicious.com/%s' },
	digg => { name => 'Digg', url => 'http://digg.com/%s' },
	dotshare => { name => 'Dotshare', url => 'http://dotshare.it/~%s' },
	facebook => { name => 'Facebook', url => 'https://facebook.com/%s' },
	flickr => { name => 'Flickr', url => 'http://www.flickr.com/people/%s/' },
	friendfeed => { name => 'FriendFeed', url => 'http://friendfeed.com/%s' },
	geeklist => { name => 'geekli.st', url => 'http://geekli.st/%s' },
	github => { name => 'GitHub', url => 'https://github.com/%s' },
	'github-meets-cpan' => { name => 'Github Meets CPAN', url => 'http://github-meets-cpan.com/user/%s' },
	gitorious => { name => 'Gitorious', url => 'https://gitorious.org/~%s' },
	gittip => { name => 'Gittip', url => 'https://www.gittip.com/%s' },
	googleplus => { name => 'Google+', url => 'http://plus.google.com/%s' },
	hackernews => { name => 'Hacker News', url => 'http://news.ycombinator.com/user?id=%s' },
	identica => { name => 'Identi.ca', url => 'http://identi.ca/%s' },
	klout => { name => 'Klout', url => 'http://klout.com/#/%s' },
	lastfm => { name => 'LastFM', url => 'http://www.last.fm/user/%s' },
	linkedin => { name => 'LinkedIn', url => 'http://www.linkedin.com/in/%s' },
	myspace => { name => 'MySpace', url => 'http://www.myspace.com/%s' },
	nerdability => { name => 'NerdAbility', url => 'https://nerdability.com/user/%s' },
	newsblur  => { name => 'Newsblur', url => 'http://%s.newsblur.com' },
	ohloh => { name => 'Ohloh', url => 'https://www.ohloh.net/accounts/%s' },
	perlmonks => { name => 'PerlMonks', url => 'http://www.perlmonks.org/?node=%s' },
	pinboard => { name => 'Pinboard', url => 'http://pinboard.in/u:%s' },
	playperl => { name => 'Play Perl', url => 'http://play-perl.org/player/%s' },
	posterous => { name => 'Posterous', url => 'http://%s.posterous.com/' },
	prepan => { name => 'PrePAN', url => 'http://prepan.org/user/%s' },
	reddit => { name => 'Reddit', url => 'http://www.reddit.com/user/%s' },
	slideshare => { name => 'SlideShare', url => 'http://www.slideshare.net/%s' },
	sourceforge => { name => 'SourceForge', url => 'http://sourceforge.net/users/%s' },
	speakerdeck => { name => 'SpeakerDeck', url => 'https://speakerdeck.com/u/%s' },
	stackoverflow => { name => 'StackOverflow', url => 'http://stackoverflow.com/users/%s/' },
	steam => { name => 'Steam', url => 'http://steamcommunity.com/id/%s' },
	stumbleupon => { name => 'StumbleUpon', url => 'http://www.stumbleupon.com/stumbler/%s/' },
	tumblr => { name => 'Tumblr', url => 'http://%s.tumblr.com/' },
	twitter => { name => 'Twitter', url => 'http://twitter.com/%s' },
	vimeo => { name => 'Vimeo', url => 'http://vimeo.com/%s' },
	youtube => { name => 'Youtube', url => 'http://www.youtube.com/user/%s' },
);

package RDF::LinkedData::MetaCPAN::Person 0.001 {
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
	
	has cpanid => (
		is        => 'ro',
		isa       => CpanId,
		required  => !!1,
	);
	
	method uri ()
	{
		sprintf 'http://purl.org/NET/cpan-uri/person/%s', lc($self->cpanid);
	}
	
	method descriptor_uri ()
	{
		sprintf 'http://ontologi.es/cpan-data/person/%s', lc($self->cpanid);
	}
	
	method base_statements ()
	{
		return (
			st( iri($self->uri),            curie('rdf:type'),              curie('foaf:Agent') ),
			st( iri($self->uri),            curie('foaf:nick'),             literal($self->cpanid) ),
		);
	}
	
	method additional_statements ()
	{
		return (
			$self->_profile_statements,
			$self->_release_statements,
		);
	}
	
	method _profile_statements ()
	{
		my $data = $self->metacpan->author( pauseid => $self->cpanid );
		
		my @st;
		for (@{ $data->{blog} || [] })
		{
			push @st, st( iri($self->uri), curie('foaf:weblog'), iri($_->{url}) ) if $_->{url};
		}
		for (@{ $data->{email} || [] })
		{
			push @st, st( iri($self->uri), curie('foaf:mbox'), iri("mailto:$_") );
		}
		for (grep defined, $data->{gravatar_url})
		{
			push @st, st( iri($self->uri), curie('foaf:depiction'), iri($_) );
		}
		for (@{ $data->{website} || [] })
		{
			push @st, st( iri($self->uri), curie('foaf:homepage'), iri($_) );
		}
		
		for (@{ $data->{profile}||[] }, @{ $data->{donation}||[] })
		{
			$_ && $_->{id} or next;
			
			my $service = $SERVICES{$_->{name}};
			my $account = $service->{url} ? iri(sprintf $service->{'url'}, $_->{id}) : RDF::Trine::blank();
			
			push @st, (
				st( iri($self->uri), curie('foaf:account'), $account ),
				st( $account, curie('rdf:type'), curie('foaf:OnlineAccount') ),
				st( $account, curie('foaf:accountName'), literal($_->{id}) ),
			);
		}
		
		for (grep defined, $data->{location})
		{
			my $place = RDF::Trine::blank();
			
			push @st, (
				st( iri($self->uri), curie('foaf:based_near'), $place ),
				st( $place, curie('geo:longitude'), $_->[0] ),
				st( $place, curie('geo:latitude'), $_->[1] ),
			);
		}
		
		return @st;
	}
	
	method _release_statements ()
	{
		my $data = $self->metacpan->release(
			search => {
				author => $self->cpanid . ' AND ', # wtf?
				size   => 4000,
				fields => 'name,distribution,version,abstract,date,status',
			},
		);
		
		my @st;
		my @always = ( metacpan => $self->metacpan, author => $self->cpanid );
		
		for my $r (@{ $data->{hits}{hits} })
		{
			require RDF::LinkedData::MetaCPAN::Release;
			my $release = 'RDF::LinkedData::MetaCPAN::Release'->new(@always, %{$r->{fields}});
			push @st, st( iri($release->uri), curie('dc:publisher'), iri($self->uri) );
			push @st, $release->base_statements;
		}
		
		return;
	}
}

1;

use v5.14;

package RDF::LinkedData::MetaCPAN::Types 0.001 {
	our $AUTHORITY = 'cpan:TOBYINK';
	
	use Type::Tiny 0.016 ();
	use Type::Utils -all;
	
	use Type::Library -base, -declare => qw(
		DistName
		ModuleName
		PackageName
		VersionStr
		CpanId
		ReleaseName
	);
	
	use Module::Runtime ();
	use version ();
	
	BEGIN {
		extends qw( Types::Standard );
	}
	
	declare DistName,
		as Str,
		where     { return if /:/; my $d = ($_ =~ s/-/::/r); $d =~ $Module::Runtime::module_name_rx },
		inline_as { return (undef, "($_ =~ /:/) ? !!0 : do { my \$d = ($_ =~ s/-/::/r); \$d =~ \$Module::Runtime::module_name_rx }") };
	
	declare ModuleName,
		as        Str,
		where     { $_ =~ $Module::Runtime::module_name_rx },
		inline_as { return (undef, "$_ =~ \$Module::Runtime::module_name_rx") };
	
	declare PackageName,
		as        ModuleName;
	
	declare VersionStr,
		as        StrMatch[ qr{^\S+$} ];
#		where     { version::is_lax($_) }
#		inline_as { return (undef, "version::is_lax($_)") };
	
	declare CpanId,
		as        StrMatch[ qr{^[A-Z][A-Z0-9]{1,31}$} ];
	
	coerce CpanId, from Str, q{ uc($_) };
	coerce CpanId, from HasMethods['cpanid'], q{ $_->cpanid };
	
	declare ReleaseName,
		as        Str,
		where {
			my ($author, $rest)  = split '/';
			my ($dist, $version) = ($rest =~ /^(.+)-([^-]+(?:\-TRIAL)?)$/);
			CpanId->check($author) and DistName->check($dist);
		};
}

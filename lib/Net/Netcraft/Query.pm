package Net::Netcraft::Query;

use strict;
use warnings;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $LIBRARY);

use Exporter ();
@ISA = qw(Exporter);
@EXPORT_OK = qw(host site timeout http_proxy user_agent query);

$VERSION = '0.03';
$LIBRARY = __PACKAGE__;

use HTTP::Request::Common qw(GET);
use LWP;

$|=1;

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	return $self->init(@_);
}

sub init {
	my $self = shift;
	my %args = @_;

	map($self->{$_}=$args{$_}, keys %args);

	return $self;
}

sub query {
	my $self = shift;
	
	my $host        = $self->{host};
	my $site        = $self->{site}; 
	my $timeout     = $self->{timeout};
	my $http_proxy  = $self->{http_proxy};
	my $user_agent  = $self->{user_agent};
	my $print_error = $self->{print_error};

	$host        = $host        ? $host        : "http://toolbar.netcraft.com/site_report?url=http://"; 
	$timeout     = $timeout     ? $timeout     : 10; 
	$user_agent  = $user_agent  ? $user_agent  : "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)"; 
	$print_error = $print_error ? $print_error : 0; 

	my $row;
	my $his;
	my @res;
	my %res;

	$SIG{ALRM} = \&timed_out;
	eval{
		alarm($timeout);

		my $ua = LWP::UserAgent->new;
		$ua->agent($user_agent);
		$ua->timeout($timeout);
		$ua->proxy("http",$http_proxy) if $http_proxy;

		my $url = $host . $site;
		my $req = GET $url;
		my $res = $ua->request($req);

		if ($res->is_success){
			$res = $res->content;
			@res = split(/\n|\r/,$res);
			$his = $res;
		} else {
			print $res->status_line if $print_error == 1;
		}
		
		alarm(0);
	};

	foreach $row (@res){

		# site
		if ($row =~ /<b>Site<\/b>/){
			if ($row =~ m/_blank">(.*)<\/a>/){
				$res{ 'site' } = $1;
			}
		}

		# last reboot
		if ($row =~ /<b>Last reboot<\/b>/){
			if ($row =~ m/<a href="http:\/\/uptime.netcraft.com\/up\/graph\?site=$site\">(.*)<\/a>&nbsp;/){
				$res{ 'last_reboot' } = $1;
			}
		}

		# domain 
		if ($row =~ /<b>Domain<\/b>/){
			if ($row =~ m/<a href="http:\/\/searchdns.netcraft.com\/\?host=(.*)">(.*)<\/a>/){
				$res{ 'domain' } = $2;
			}
		}

		# netblock owner 
		if ($row =~ /<b>Netblock owner<\/b>/){
			if ($row =~ m/<a href="\/netblock\?q=(.*)">(.*)<\/a>/){
				$res{ 'netblock_owner' } = $2;
			}
		}
	
		# ip address 
		if ($row =~ /<b>IP address<\/b>/){
			if ($row =~ m/(\d+)\.(\d+)\.(\d+)\.(\d+)/){
				$res{ 'ip_address' } = "$1.$2.$3.$4";
			}
		}
	
		# site rank 
		if ($row =~ /<b>Site rank<\/b>/){
			if ($row =~ m/<a href="\/stats\/topsites\?s=(.*)">(\d+)<\/a>/){
				$res{ 'site_rank' } = $2;
			}
		}

		# country 
		if ($row =~ /<b>Country<\/b>/){
			if ($row =~ m/<img src='\/images\/flags\/(.*).gif' border=0>&nbsp;(.*)<\/a>/){
				$res{ 'country' } = $2;
			}
		}
	
		# nameserver 
		if ($row =~ /<b>Nameserver<\/b>/){
			if ($row =~ m/<td><b>Nameserver<\/b><\/td><td>(.*)<\/td>/){
				$res{ 'nameserver' } = $1;
			}
		}
	
		# date first seen 
		if ($row =~ /<b>Date first seen<\/b>/){
			if ($row =~ m/<td><b>Date first seen<\/b><\/td><td>(.*)<\/td>/){
				$res{ 'date_first_seen' } = $1;
			}
		}
	
		# dns admin 
		if ($row =~ /<b>DNS admin<\/b>/){
			if ($row =~ m/<td><b>DNS admin<\/b><\/td><td>(.*)<\/td>/){
				$res{ 'dns_admin' } = $1;
			}
		}
	
		# domain registry 
		if ($row =~ /<b>Domain Registry<\/b>/){
			if ($row =~ m/<td><b>Domain Registry<\/b><\/td><td>(.*)<\/td>/){
				$res{ 'domain_registry' } = $1;
			}
		}
	
		# reverse dns 
		if ($row =~ /<b>Reverse DNS<\/b>/){
			if ($row =~ m/<td><b>Reverse DNS<\/b><\/td><td>(.*)<\/td>/){
				$res{ 'reverse_dns' } = $1;
			}
		}
	
		# organisation 
		if ($row =~ /<b>Organisation<\/b>/){
			if ($row =~ m/<td><b>Organisation<\/b><\/td><td>(.*)<\/td>/){
				$res{ 'organisation' } = $1;
			}
		}
	
		# nameserver organisation 
		if ($row =~ /<b>Nameserver Organisation<\/b>/){
			if ($row =~ m/<td><b>Nameserver Organisation<\/b><\/td><td>(.*)<\/td>/){
				$res{ 'nameserver_organisation' } = $1;
			}
		}
	}

	$his =~ m/<br><table class=TBtable><caption>Hosting History<\/caption>(.*)<\/table><br>/;	
	if (defined($1)){
		my @his = split(/<\/td><\/tr>/,$1);
		my $n = 0;
        	for my $i (0..10) { $res{ "history_$i" } = ''; }
		foreach $row (@his){
			$n++;
			if ($row =~ m/<tr class=TB(.*)><td><a href="\/netblock\?q=(.*)">(.*)<\/a><\/td><td>(\d+)\.(\d+)\.(\d+)\.(\d+)<\/td><td>(.*)<\/td><td>(.*)<\/td><td>(.*)/){
				$res{ "history_$n" } = "$3:$4.$5.$6.$7:$8:$9:$10";
			}
		}
	}

	return %res;
}

sub timed_out {
	die "Timeout while connecting to server!\n";
}

1;
__END__

=head1 NAME

Net::Netcraft::Query - Query the Netcraft webserver search

=head1 SYNOPSIS

  use Net::Netcraft::Query;

  my $site = "www.juventus.it";

  my $req = Net::Netcraft::Query->new(
    site => $site,
  );

  my %res = $req->query;

  print "Site                    : " . $res{site} . "\n";
  print "Domain                  : " . $res{domain} . "\n";
  print "IP Address              : " . $res{ip_address} . "\n";
  print "Nameserver              : " . $res{nameserver} . "\n";
  print "Reverse Dns             : " . $res{reverse_dns} . "\n";
  print "Country                 : " . $res{country} . "\n";
  print "Nameserver Organisation : " . $res{nameserver_organisation} . "\n";
  print "Date First Seen         : " . $res{date_first_seen} . "\n";
  print "Dns Admin               : " . $res{dns_admin} . "\n";
  print "Organisation            : " . $res{organisation} . "\n";
  print "Domain Registry         : " . $res{domain_registry} . "\n";
  print "Last Reboot             : " . $res{last_reboot} . "\n";
  print "Netblock Owner          : " . $res{netblock_owner} . "\n";

  print "\n";

  print "History 1               : " . $res{history_1} . "\n";
  print "History 2               : " . $res{history_2} . "\n";

=head1 DESCRIPTION

This module allows you to query the Netcraft webserver search service.

Please visit http://news.netcraft.com/ for more information.

=head1 METHODS

=head2 new

The constructor. Given a web site returns a L<Net::Netcraft::Query> object:

  my $req = Net::Netcraft::Query->new(
    site => $site,
  );

=over 2

=item B<host>

Default is 'http://toolbar.netcraft.com/site_report?url=http://';

=item B<site>

Web site to check (required);

=item B<timeout>

Default is 10;

=item B<http_proxy>

A URL for proxy-ing HTTP requests.

=item B<user_agent>

Default is 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)'.

=back

=head2 query 

It returns a hash containing all results (country, date_first_seen, dns_admin, domain, domain_registry, history_1 - history_10, ip_address, last_reboot, nameserver, nameserver_organisation, netblock_owner, organisation, reverse_dns, site, site_rank); 

  my %res = $req->query;

=head1 SEE ALSO

Netcraft Services, http://news.netcraft.com/

=head1 AUTHOR

Matteo Cantoni, E<lt>matteo.cantoni@nothink.org<gt>

=head1 CONTRIBUTORS

Joshua D. Abraham

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007,2008 by Matteo Cantoni 

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

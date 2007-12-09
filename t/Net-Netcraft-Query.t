use Test::More tests => 1;
BEGIN { use_ok('Net::Netcraft::Query') };

my $site = "www.juventus.it";

my $req = Net::Netcraft::Query->new(
	site => $site,
);

my %res = $req->query;

print "Site                    : " . $res{site} . "\n";
print "Last reboot             : " . $res{last_reboot} . "\n";
print "Domain                  : " . $res{domain} . "\n";
print "Netblock_owne           : " . $res{netblock_owner} . "\n";
print "Ip address              : " . $res{ip_address} . "\n";
print "Site rank               : " . $res{site_rank} . "\n";
print "Country                 : " . $res{country} . "\n";
print "Nameserver              : " . $res{nameserver} . "\n";
print "Date first seen         : " . $res{date_first_seen} . "\n";
print "Dns admin               : " . $res{dns_admin} . "\n";
print "Domain registry         : " . $res{domain_registry} . "\n";
print "Reverse dns             : " . $res{reverse_dns} . "\n";
print "Organisation            : " . $res{organisation} . "\n";
print "Nameserver organisation : " . $res{nameserver_organisation} . "\n";

print "\n";

print "History 1               : " . $res{history_1} . "\n";
print "History 2               : " . $res{history_2} . "\n";
print "History 3               : " . $res{history_3} . "\n";
print "History 4               : " . $res{history_4} . "\n";
print "History 5               : " . $res{history_5} . "\n";
print "History 6               : " . $res{history_6} . "\n";
print "History 7               : " . $res{history_7} . "\n";
print "History 8               : " . $res{history_8} . "\n";
print "History 9               : " . $res{history_9} . "\n";
print "History 10              : " . $res{history_10} . "\n";

print "\n";

exit(0);

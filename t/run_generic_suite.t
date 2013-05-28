use strict;
use warnings;
use Test::More;
use Test::Deep;
use HURON::RecDescent;
use JSON;

sub slurp_file {
	my $fn = shift;
	open (my $fh, '<:encoding(utf8)', $fn) or die ('Could not open: '.$fn);
	my $s = '';
	while (my $line = <$fh>) {
		$s .= $line;
	}
	$s;
}

my $huron_parser = HURON::RecDescent->new;
sub get_huron_from {
	my $file = shift;
	my $raw = slurp_file $file;
	$huron_parser->parse($raw);
}

my $json_parser = JSON->new->allow_nonref;
sub get_json_from {
	my $file = shift;
	my $raw = slurp_file $file;
	$json_parser->decode($raw);
}

foreach my $case (qw(
s01 s02 s03 s04 s05 s06 s07 s08
a01 a02 a03 a04 a05 a06
)) {
	my $huron;
	my $remainder;
	eval {
		($huron, $remainder) = get_huron_from("t/generic_suite/$case.huron");
	};
	fail $case.":\n".$@ if $@;
	fail $case.": Text remains:\n".$remainder if defined $remainder and $remainder =~ /\S/;
	my $json;
	eval{
		$json = get_json_from("t/generic_suite/$case.json");
	};
	fail $case.":\n".$@ if $@;
	use Data::Dumper;
	cmp_deeply ($huron, $json, $case) or diag Dumper $huron;
}
done_testing;


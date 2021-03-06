
{
	package HURON::Insignificant;

	use Moo;

	1;
}
package HURON::RecDescent;

use 5.006;
use strict;
use warnings;
use Moo;
use Parse::RecDescent;

=head1 NAME

HURON::RecDescent - Recursive Descent Parser for HURON

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

	use HURON::RecDescent;

	my $parser = HURON::RecDescent->new();
	$parser->parse('{id:"44"}')
	...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 parse

=cut

sub _significant {
	my $s = exists $_[0] ? $_[0] : $_ ;
	return defined ref $s ?
		(ref $s) ne 'HURON::Insignificant'
	 : 1;
	return 1;
}
sub _unesc {
	my $s = shift;
	$s = s/^\\//;
	return $s;
}
sub _top_and_tail {
	my @items = @_;
	shift @items;
	shift @items;
	pop @items;
	my $s; 
	$s .= (ref $_ ? join '', @$_ : $_ ) foreach @items;
	#join '', @items;
	$s;
}
$Parse::RecDescent::skip = qr//;
our $grammar = q`
document: ( hash | array | scalar | array_contents | hash_contents )

hash: '{' hash_contents '}' { $return = $item{hash_contents} }

array: '[' array_contents ']' { $return = $item{array_contents} }

scalar: ( single_quoted_string | double_quoted_string| token )

value: ( scalar | hash | array )

key: (single_quoted_string|double_quoted_string|token)

single_quoted_string: "'" (escaped_backslash|escaped_special|escaped_double_quote|escaped_single_quote|not_single_quote)(s?) "'" { $return = &HURON::RecDescent::_top_and_tail (@item) }

double_quoted_string: '"' (escaped_backslash|escaped_special|escaped_double_quote|escaped_single_quote|not_double_quote)(s?) '"' { $return = &HURON::RecDescent::_top_and_tail (@item) }

hash_contents: (json_hash_contents|yaml_hash_contents)

array_contents: (json_array_contents|yaml_array_contents)

json_array_contents: (optional_multiline_space | json_array_item(s?) lone_item | json_array_item(s)) { shift @item; $return = [ grep { &HURON::RecDescent::_significant($_)} @item ] }

lone_item: (value) { shift @item; $return = shift @{[ grep { &HURON::RecDescent::_significant($_) } @item ]} }

json_array_item: (optional_multiline_space lone_item comma optional_multiline_space) { shift @item; $return = [grep { &HURON::RecDescent::_significant($_) } @item] }

yaml_array_contents: (optional_multiline_space|yaml_array_item(s?)) { shift @item; $return = [ grep { &HURON::RecDescent::_significant($_) } @item ] }

yaml_array_item: (optional_multiline_space newline_plus_dash value (optional_space comma)(?) optional_space) { $return  = $item{value} }

json_hash_contents: (optional_multiline_space|json_hash_pair(s?)) {  shift @item; $return = { map { @$_ } grep { &HURON::RecDescent::_significant($_) } @item } }

json_hash_pair: (optional_multiline_space key optional_space colon optional_space value comma optional_space(s)) { $return  = [$item{key}, $item{value}] }

yaml_hash_contents: (optional_multiline_space|yaml_hash_pair(s?)) { shift @item;  $return = { map { @$_ } grep { &HURON::RecDescent::_significant($_) } @item } }

yaml_hash_pair: (optional_multiline_space newline key optional_space colon optional_space value (optional_space comma)(?) optional_space(s)) { $return  = [$item{key}, $item{value}] }

token: /-?[[:alnum:]_][[:alnum:]_\\-]*/

true: "true" { $return = 1 }

false: "false" { $return = 0 }

undefined: "~" { $return = undef }

colon: /:|=>/ { $return = HURON::Insignificant->new; }

comma: /,/ { $return = HURON::Insignificant->new; }

escaped_backslash: /\\\\\\\\/ { $return = '\\\\' }

escaped_single_quote: /\\\\'/ { $return = "'" }

escaped_double_quote: /\\\\"/ { $return = '"' }

escaped_special: /\\\\([^\\\\"'])/ { $return=&HURON::RecDescent::_unesc(shift @item) }

number: /\\d+(?!=[[:alnum:]])/

newline: /\\n/ { $return = HURON::Insignificant->new; }

newline_plus_dash: /\\s*\\n\\s*-[\\x20\\t]/ { $return = HURON::Insignificant->new; }

optional_space: /[\\t\\x20]*?/ { $return = HURON::Insignificant->new; }

optional_multiline_space: /[\\n\\r\\t\\s]*?/ { $return = HURON::Insignificant->new; }

not_double_quote: /[^"\\x00-\\x1F\\\\]+/ 

not_single_quote: /[^'\\x00-\\x1F\\\\]+/
`;

$::RD_HINT = 1 if defined $ENV{RD_HINT} and $ENV{RD_HINT} eq '1';
our $parser = Parse::RecDescent->new($grammar);
sub parse {
	my $self = shift;
	my $input = shift;
	my ($output, $remainder) = $parser->document($input);
	return $output;
}


=head1 AUTHOR

Daniel Perrett, C<< <perrettdl at googlemail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-huron at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HURON>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HURON::RecDescent


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HURON>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HURON>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HURON>

=item * Search CPAN

L<http://search.cpan.org/dist/HURON/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Daniel Perrett.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of HURON::RecDescent

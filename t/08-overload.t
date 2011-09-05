#!/usr/bin/env perl

package Queen;
use v5.10;
use Want::Boolean 'wantbool';
use overload no_method => \&mybool;

sub mybool { wantbool() ~~ [qw/AND NOT/] }
sub new { bless {} }

package main;

use Test::Most tests => 1;

my $daresay = qq("I daresay you haven't had much practice," \
said the Queen. "When I was your age, I always did it for half-\
an-hour a day. Why, sometimes I've believed as many as six impo\
ssible things before breakfast. There goes the shawl again!");
my $spake_the_queen = sub {
	my $a = Queen->new;
	return $daresay if $a && !$a;
};
is $spake_the_queen->() => $daresay, "Hooray?";

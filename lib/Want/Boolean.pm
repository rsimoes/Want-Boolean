package Want::Boolean;

use 5.010;
use strict;
use warnings;
use utf8::all;
use B::Flags;
use B::Utils 'walkoptree_simple';
use B::Utils::OP qw/parent_op return_op/;
use List::AllUtils 'any';
use Sub::Exporter -setup => {
	exports => ['wantbool']
};

# VERSION

sub wantbool  {
	my ( $found_op, $start_op );

	my $walk_callback = sub {
		my $op = shift;
		if ( _check_wanted($op) ) {
			$found_op = $op->name;
			if (
					$found_op ne 'not'
					&& any { $_->oldname eq 'not' } $op->descendants
			) {
				$found_op = 'not';
			}
		}
	};

	# Set starting op and look for opportunities to return early:
	my $return_op = return_op(1);
	my $parent_op = parent_op(1);
	if ( $return_op->flagspv eq 'WANT_VOID' ) {
		$start_op = $parent_op->next->next;
		$found_op = $start_op->name if _check_wanted($start_op);
	} else {
		$start_op = $return_op;
		$found_op = 'not' if $start_op->name eq 'not';
	}

	# Find and return the LOGOP, or return undef:
	walkoptree_simple($start_op, $walk_callback) if !$found_op;
	$found_op = uc $found_op if $found_op;
	return $found_op;
}

sub _check_wanted {
	my $op = shift;
	state $wanted_ops = [qw/and or xor not/];
	return any { $op->name eq $_ } @$wanted_ops;
}

1;

# ABSTRACT: Determine a sub's calling boolean operator

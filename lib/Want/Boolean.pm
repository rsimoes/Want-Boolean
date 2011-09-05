package Want::Boolean;

use v5.10;
use strict;
use warnings;
use utf8::all;

use B::Utils::OP 'return_op';
use Data::Dump 'dump';
use Devel::Caller;
use Sub::Exporter -setup => {
	exports => ['wantbool'],
};

# VERSION

# Op types:
use constant {
	NULL      => 0,
	NOT       => 96,
	AND       => 164,
	OR        => 165,
	XOR       => 166,
	COND_EXPR => 168,
	SCOPE     => 186,
	LINESEQ   => 180,
	ENTERLOOP => 189,
	ENTERWHEN => 201
};
use constant {
	BOOLS     => [ NOT, AND, OR, XOR, COND_EXPR, ENTERWHEN ]
};

#sub B::OP::print_it {
#	my ( $self ) = @ARG;
#	print "    " . B::peekop($self);
#}

sub wantbool  {

	# Look for cases to return early:
	return undef if not defined ((caller 1)[5]);
	my $return_op = return_op(1);
	if ( not $$return_op ) { # Overloaded?
		my $self = Devel::Caller::_context_op( PadWalker::_upcontext(0) );
		$return_op = $self->parent;
	}
	my $op_type = $return_op->type;
	$op_type ~~ BOOLS or return '';

	# Look for "unobvious" boolean ops:
	my $child1 = $return_op->first;
	if ( $op_type !~~ [ NOT, XOR ] && $child1->targ == NOT ) {
		$op_type = NOT;       # Optimized away NOT operator
	} elsif ( $op_type == AND ) {
		my $child2 = $child1->sibling;
		my $c2_type = $child2->type;
		if ( $c2_type == SCOPE ) {
			$op_type = COND_EXPR; # Simple conditional handled by AND
		} elsif ( $c2_type == LINESEQ ) {
			$op_type = ENTERLOOP; # While or for loop
		}
	}

	state $op_names = {
		NOT()       => 'NOT',
		AND()       => 'AND',
		OR()        => 'OR',
		XOR()       => 'XOR',
		COND_EXPR() => 'COND',
		ENTERWHEN() => 'WHEN',
		ENTERLOOP() => 'LOOP'
	};
	return $op_names->{$op_type};
}

1;

# ABSTRACT: Determine a sub or eval block's calling boolean operator

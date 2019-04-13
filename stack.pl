/*						*/	
/*   Stack Functions    */
/*						*/	

%ifndef def_domains INCLUDE "globals.pro" enddef
/*

PREDICATES
	init_stack
	push(move,i)
	pull(move,i)
	get(move,i,i)
	get_0(move,i)
	replace(move,i)

CLAUSES
*/

init_stack :-	
	not(top(_)),
	asserta(top(0)).

push(Move,Value) :-
	retract(top(Old)),
	New is Old+1,
	asserta(top(New)),
	asserta(stack(Move,Value,New)),!.
	
pull(Move,Value) :-
	retract(top(Old)),!,	/* Cut appended... debug !!! */
	New is Old-1,
	asserta(top(New)),
	retract(stack(Move,Value,Old)),!.
	
get(Move,Value,Depth) :-
	top(Top),
	Act is Top-Depth,
	stack(Move,Value,Act),!.

get_0(Move,Value) :-
	top(Top),
	stack(Move,Value,Top),!.
	
replace(Move,Value) :-	
	top(Top),
	retract(stack(_,_,Top)),
	asserta(stack(Move,Value,Top)),!.


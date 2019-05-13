% *********************************
% store globel predicates
% *********************************


%database
:- dynamic
	stack/2,
	top/1,
	human/1,
	depth/1,
	board/2.

% invalid_field(X): X is invalid position
invalid_field(X):-
	X =< 10,!.
invalid_field(X):-
	X >= 89,!.
invalid_field(X):-
	0 is X mod 10,!.
invalid_field(X):-
	9 is X mod 10,!.
	
% exist: check if there is a piece of certain half in the field
exist(Field,half_position(X,_,_,_,_,_,_),pawn):-
	member(Field,X).
exist(Field,half_position(_,X,_,_,_,_,_),rook):-
	member(Field,X).
exist(Field,half_position(_,_,X,_,_,_,_),knight):-
	member(Field,X).
exist(Field,half_position(_,_,_,X,_,_,_),bishop):-
	member(Field,X).
exist(Field,half_position(_,_,_,_,X,_,_),queen):-
	member(Field,X).
exist(Field,half_position(_,_,_,_,_,X,_),king):-
	member(Field,X).

% invert: between black and white
invert(F1,F2):-
	F1 = black,
	F2 = white.
invert(F1,F2):-
	F1 = white,
	F2 = black.

% remove(Elem, List, ListNew)
remove(X,[X|New],New):- !.
remove(X,[A|Old],[A|New]):-
	remove(X,Old,New).


%****************************************************************
%								*
%	SCHACH V1.0, (c) 1992 by Martin Ostermann and		*
%				 Frank Bergmann			*
%								*
%	File "ZUG_GEN.PRO"					*
%								*
%	Move Generator for the SCHACH 1.0 Program		*
%								*
%	IMPORT: 						*
%		<none>						*
%								*
%	EXPORT:							*
%		all_moves(Color,Position,Move)			*
%								*
%	TEST:							*
%		zug_gen()					*
%								*
%****************************************************************

%ifndef def_domains INCLUDE "globals.pro" enddef
/*
PREDICATES
	one_step(i,i,i,color,position)
	call_multiple(i,i,i,color,position)
	multiple(i,i,i,color,position)
	half(position,half_position,color)
        add_half(position,half_position,color,position)
        poss_move(type,i)

	pawn_move(i,color,position,i)
	longmove(i,color,type,position,i)
        shortmove(i,color,type,position,i)
        occupied(i,color,position)
        fre(i,position)
	all_moves(color,position,move)
	
	zug_gen

CLAUSES
*/

one_step(Field,Direction,Next,Color,Position):-	
	Next  is  Field + Direction,
	not(rand(Next)),
	not(occupied(Next,Color,Position)).

call_multiple(Field,Direct,Next,Color,Position):-
	Step  is  Field + Direct,
	multiple(Step,Direct,Next,Color,Position).

multiple(Field,_,_,_,_):-
	rand(Field),
	!,fail.
multiple(Field,_,_,Color,Position):-
 	occupied(Field,Color,Position),
 	!,fail.
multiple(Field,_,Field,Color,Position):-
	invert(Color,Oppo),
	occupied(Field,Oppo,Position),!.
multiple(Field,_,Field,_,_).
multiple(Field,Direction,Next,Color,Position):-
	Step  is  Field + Direction,
	multiple(Step,Direction,Next,Color,Position).
	
half(position(Half,_,_),Half,white).
half(position(_,Half,_),Half,black).

add_half(position(_,Y,Z),Half,white,position(Half,Y,Z)).
add_half(position(X,_,Z),Half,black,position(X,Half,Z)).

occupied(Field,white,position(Stones,_,_)):-
	exist(Field,Stones,_).	
occupied(Field,black,position(_,Stones,_)):-
	exist(Field,Stones,_).	

fre(Field,Position):-
	not(occupied(Field,white,Position)),
	not(occupied(Field,black,Position)),
	not(rand(Field)).

poss_move(rook,10).
poss_move(rook,-10).
poss_move(rook,1).
poss_move(rook,-1).
poss_move(bishop,9).
poss_move(bishop,11).
poss_move(bishop,-9).
poss_move(bishop,-11).
poss_move(knight,19).
poss_move(knight,21).
poss_move(knight,8).
poss_move(knight,12).
poss_move(knight,-8).
poss_move(knight,-12).
poss_move(knight,-19).
poss_move(knight,-21).
poss_move(queen,X):-
	poss_move(rook,X).
poss_move(queen,X):-
	poss_move(bishop,X).
poss_move(king,X):-
	poss_move(queen,X).
	
		
pawn_move(From,white,Position,To):-
	To  is  From + 9,
	occupied(To,black,Position).
pawn_move(From,white,Position,To):-
	To  is  From + 10,
	fre(To,Position).
pawn_move(From,white,Position,To):-
	To  is  From + 11,
	occupied(To,black,Position).
pawn_move(From,white,Position,To):-
	To  is  From + 20,
	Over  is  From + 10,
	fre(To,Position),
	fre(Over,Position),
	Row  is  From // 10,
	Row = 2.
pawn_move(From,black,Position,To):-
	To  is  From - 9,
	occupied(To,white,Position).
pawn_move(From,black,Position,To):-
	To  is  From - 10,
	fre(To,Position).
pawn_move(From,black,Position,To):-
	To  is  From - 11,
	occupied(To,white,Position).
pawn_move(From,black,Position,To):-
	To  is  From - 20,
	Over  is  From - 10,
	fre(To,Position),
	fre(Over,Position),
	Row  is  From // 10,
	Row = 7.

longmove(From,Color,Typ,Position,To):-
	poss_move(Typ,Direction),
	call_multiple(From,Direction,To,Color,Position).
shortmove(From,Color,Typ,Position,To):-
	poss_move(Typ,Direction),
	one_step(From,Direction,To,Color,Position).
	
all_moves(Color,Position,move(From,To)):-
	half(Position,half_position(Bauern,_,_,_,_,_,_),Color),
	single(From,Bauern),
	pawn_move(From,Color,Position,To).
all_moves(Color,Position,move(From,To)):-
	half(Position,half_position(_,Rookies,_,_,_,_,_),Color),
	single(From,Rookies),
	longmove(From,Color,rook,Position,To).
all_moves(Color,Position,move(From,To)):-
	half(Position,half_position(_,_,Knights,_,_,_,_),Color),
	single(From,Knights),
	shortmove(From,Color,knight,Position,To).
all_moves(Color,Position,move(From,To)):-
	half(Position,half_position(_,_,_,Bishies,_,_,_),Color),
	single(From,Bishies),
	longmove(From,Color,bishop,Position,To).
all_moves(Color,Position,move(From,To)):-
	half(Position,half_position(_,_,_,_,Queenies,_,_),Color),
	single(From,Queenies),
	longmove(From,Color,queen,Position,To).
all_moves(Color,Position,move(King,To)):-
	half(Position,half_position(_,_,_,_,_,[King],_),Color),
	shortmove(King,Color,king,Position,To).

zug_gen:-
	PawnWhite = [21,22,23,24,25,26,27,28],
	PawnBlack = [71,72,73,74,75,76,77,78],
	H1 = half_position(PawnWhite,[11,18],[12,17],[13,16],[14],[15],notmoved),
	H2 = half_position(PawnBlack,[81,88],[82,87],[83,86],[84],[85],notmoved),
	Position = position(H1,H2,0),
	
	all_moves(white,Position,Move),
	  write(Move),nl,
	fail.

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
%		all_moves(Color,Stellung,Move)			*
%								*
%	TEST:							*
%		zug_gen()					*
%								*
%****************************************************************

%ifndef def_domains INCLUDE "globals.pro" enddef
/*
PREDICATES
	one_step(i,i,i,color,stellung)
	call_multiple(i,i,i,color,stellung)
	multiple(i,i,i,color,stellung)
	half(stellung,halbstellung,color)
        add_half(stellung,halbstellung,color,stellung)
        poss_move(type,i)

	bauermove(i,color,stellung,i)
	longmove(i,color,type,stellung,i)
        shortmove(i,color,type,stellung,i)
        occupied(i,color,stellung)
        fre(i,stellung)
	all_moves(color,stellung,move)
	
	zug_gen

CLAUSES
*/

one_step(Feld,Direction,Next,Color,Stellung):-	
	Next  is  Feld + Direction,
	not(rand(Next)),
	not(occupied(Next,Color,Stellung)).

call_multiple(Feld,Direct,Next,Color,Stellung):-
	Step  is  Feld + Direct,
	multiple(Step,Direct,Next,Color,Stellung).

multiple(Feld,_,_,_,_):-
	rand(Feld),
	!,fail.
multiple(Feld,_,_,Color,Stellung):-
 	occupied(Feld,Color,Stellung),
 	!,fail.
multiple(Feld,_,Feld,Color,Stellung):-
	invert(Color,Oppo),
	occupied(Feld,Oppo,Stellung),!.
multiple(Feld,_,Feld,_,_).
multiple(Feld,Direction,Next,Color,Stellung):-
	Step  is  Feld + Direction,
	multiple(Step,Direction,Next,Color,Stellung).
	
half(stellung(Halb,_,_),Halb,white).
half(stellung(_,Halb,_),Halb,black).

add_half(stellung(_,Y,Z),Halb,white,stellung(Halb,Y,Z)).
add_half(stellung(X,_,Z),Halb,black,stellung(X,Halb,Z)).

occupied(Feld,white,stellung(Stones,_,_)):-
	exist(Feld,Stones,_).	
occupied(Feld,black,stellung(_,Stones,_)):-
	exist(Feld,Stones,_).	

fre(Feld,Stellung):-
	not(occupied(Feld,white,Stellung)),
	not(occupied(Feld,black,Stellung)),
	not(rand(Feld)).

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
	
		
bauermove(From,white,Stellung,To):-
	To  is  From + 9,
	occupied(To,black,Stellung).
bauermove(From,white,Stellung,To):-
	To  is  From + 10,
	fre(To,Stellung).
bauermove(From,white,Stellung,To):-
	To  is  From + 11,
	occupied(To,black,Stellung).
bauermove(From,white,Stellung,To):-
	To  is  From + 20,
	Over  is  From + 10,
	fre(To,Stellung),
	fre(Over,Stellung),
	Row  is  From // 10,
	Row = 2.
bauermove(From,black,Stellung,To):-
	To  is  From - 9,
	occupied(To,white,Stellung).
bauermove(From,black,Stellung,To):-
	To  is  From - 10,
	fre(To,Stellung).
bauermove(From,black,Stellung,To):-
	To  is  From - 11,
	occupied(To,white,Stellung).
bauermove(From,black,Stellung,To):-
	To  is  From - 20,
	Over  is  From - 10,
	fre(To,Stellung),
	fre(Over,Stellung),
	Row  is  From // 10,
	Row = 7.

longmove(From,Farbe,Typ,Stellung,To):-
	poss_move(Typ,Richtung),
	call_multiple(From,Richtung,To,Farbe,Stellung).
shortmove(From,Farbe,Typ,Stellung,To):-
	poss_move(Typ,Richtung),
	one_step(From,Richtung,To,Farbe,Stellung).
	
all_moves(Color,Stellung,move(From,To)):-
	half(Stellung,halbstellung(Bauern,_,_,_,_,_,_),Color),
	single(From,Bauern),
	bauermove(From,Color,Stellung,To).
all_moves(Color,Stellung,move(From,To)):-
	half(Stellung,halbstellung(_,Rookies,_,_,_,_,_),Color),
	single(From,Rookies),
	longmove(From,Color,rook,Stellung,To).
all_moves(Color,Stellung,move(From,To)):-
	half(Stellung,halbstellung(_,_,Knights,_,_,_,_),Color),
	single(From,Knights),
	shortmove(From,Color,knight,Stellung,To).
all_moves(Color,Stellung,move(From,To)):-
	half(Stellung,halbstellung(_,_,_,Bishies,_,_,_),Color),
	single(From,Bishies),
	longmove(From,Color,bishop,Stellung,To).
all_moves(Color,Stellung,move(From,To)):-
	half(Stellung,halbstellung(_,_,_,_,Queenies,_,_),Color),
	single(From,Queenies),
	longmove(From,Color,queen,Stellung,To).
all_moves(Color,Stellung,move(King,To)):-
	half(Stellung,halbstellung(_,_,_,_,_,[King],_),Color),
	shortmove(King,Color,king,Stellung,To).

zug_gen:-
	Bauerw = [21,22,23,24,25,26,27,28],
	Bauerb = [71,72,73,74,75,76,77,78],
	H1 = halbstellung(Bauerw,[11,18],[12,17],[13,16],[14],[15],notmoved),
	H2 = halbstellung(Bauerb,[81,88],[82,87],[83,86],[84],[85],notmoved),
	Stellung = stellung(H1,H2,0),
	
	all_moves(white,Stellung,Move),
	  write(Move),nl,
	fail.

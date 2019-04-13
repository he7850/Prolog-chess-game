/*
constants
	def_domains = 1
	main_win = 1
	move_win = 2
	inp_win = 3
	tmp_inp_win = 4
	error_win = 5

domains
	i= integer
	st= string
	lc= char*
	li= integer*

	color = white ;
		black ;
		remis
	type  = pawn ;
		rook ;
		knight ;
		bishop ;
		queen ;
		king 
	feld=integer
	list=integer*
	type_list=type*
	move=move(integer,integer)
	moveflag= moved ; notmoved
	
	% comment for english speakers: 
	% -----------------------------
	%
	% "halbstellung" is German for "half-position"
	% "stellung" is German for "position"
	% "brett" - "board"
	
	halbstellung=halbstellung(list,list,list,list,list,list,moveflag)	
	stellung=stellung(halbstellung,halbstellung,i)
*/

%database
:- dynamic
	stack/2,
	top/1,
	human/1,
	depth/1,
	brett/2.

/*
PREDICATES
	rand(i)
	exist(i,halbstellung,type)
        single(i,list)
        invert(color,color)               
	remove(i,list,list)
	repeat
	for(i,i,i,i)
	end_for(i,i)
	member(type,type_list)
	member(i,list)
CLAUSES

*/
rand(X):-
	X =< 10,!.
rand(X):-
	X >= 89,!.
rand(X):-
	0 is X mod 10,!.
rand(X):-
	9 is X mod 10,!.
	
exist(Feld,halbstellung(X,_,_,_,_,_,_),pawn):-
	single(Feld,X).
exist(Feld,halbstellung(_,X,_,_,_,_,_),rook):-
	single(Feld,X).
exist(Feld,halbstellung(_,_,X,_,_,_,_),knight):-
	single(Feld,X).
exist(Feld,halbstellung(_,_,_,X,_,_,_),bishop):-
	single(Feld,X).
exist(Feld,halbstellung(_,_,_,_,X,_,_),queen):-
	single(Feld,X).
exist(Feld,halbstellung(_,_,_,_,_,X,_),king):-
	single(Feld,X).

single(X,[X|_]).
single(X,[_|Rest]):-
	single(X,Rest).

invert(F1,F2):-
	F1 = black,
	F2 = white.

invert(F1,F2):-
	F1 = white,
	F2 = black.

remove(X,[X|New],New):- !.
remove(X,[A|Old],[A|New]):-
	remove(X,Old,New).

/*
repeat.
repeat:- repeat.
*/
for(I,I,_,I):- !.	
for(I,To,_,I):- I =\= To.
for(I,To,Step,Index):-
	I =\= To,
	I1 is I + Step,
	for(I1,To,Step,Index).	
end_for(I,I).
	
/*
member(X,[X|_]).
member(X,[_|Rest]) :- member(X,Rest).
*/

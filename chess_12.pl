%****************************************************************
%															*
%	PROLOG CHESS 											*
%	Version 1.2 for standard prolog							*
%															*
%	Quick and Dirty Port on 25.6.95 by Martin Ostermann		*
%	mailto:mos@brainaid.oche.de								*
%															*
%	The original is writen in Turbo-Prolog 2.0 and contains *
%	a very nice GUI Interface.								*
%															*
%	------------------------------------------------------  *
%															*
%	This Program is the result of the 						*
%	Artificial Intelligence Project at the					*
%															*
%	Computer-Club der RWTH Aachen							*
% 	KI - Gruppe 89/90										*
%															*
%	This program belongs to the Public Domain.				*
%	The source may freely be reproduced or changed			*
%	for noncommercial purposes.								*
%	Please refer to											*
%															*
%		Frank Bergmann										*
%															*
%		fraber@cs.tu-berlin.de								*
%	    or	fraber@brainaid.oche.de							*
%															*
%	for all other purposes.									*
%															*
%****************************************************************

/* 

% !!!! For Quintus, uncomment these:

:-ensure_loaded(library(basics)).
not(X):- \+ X.

*/
:- [globals] .	% DOMAINS + common predicates
:- [zug_gen].	% Position Generator
:- [stack].		% Stack Management
:- [pos_val].	% Position Evaluation routines

/*
predicates
	newdepth(i,symbol,i)
	get_best(stellung,color,i,i,i)
	new_alpha_beta(color,i,i,i,i)
	compare_move(move,i,color)
	cutting(i,color,i,i)
	evaluate(stellung,color,i,move,i,i,i)

	enter(stellung,color,move)
	play(stellung,color)
	grundstellung (stellung)
	change(stellung,color,i,i,stellung)
	kill(stellung,color,i,stellung)
	extract(halbstellung,type,list)
        combine(halbstellung,type,list,halbstellung)
	check_00(stellung,color,i,i,stellung)
	make_move(color,stellung,move,stellung,symbol)     
	generate(move,color,stellung,stellung,symbol)
	checkflag(i,i,i,i,st,st,st)
	move_1(i,i,i,i)
	importmove(move)
	intoxy(i,i,i)
	retract_input
	remove_blank(st,st)
	inputcommand(char,st,i,i)
	check_char(char,lc)
	check_str(st,i,i)
	ilegal(st)
	is_figur(i,i,st)
	right_move(i,i,i,i,st)
	right_move_1(i,i,i,i,st)
	exportmove(move)
	edit_move(char,st)
	echo_char(char,st)
	outtext_move(char,char,st,st,st)
	outtext_move_1(st,i,i,i,i,st)
	run
	
CLAUSES
*/

frontchar(I,C,R):-
	nonvar(I),
	name(I,S),
	S = [Char|Rest],
	name(R,Rest),
	name(C,[Char]),!.
frontchar(I,C,R):-
	nonvar(C),nonvar(R),
	name(Rest,R),
	name([Char],C),
	S = [Char|Rest],
	name(I,S),!.

str_char(S,C):-
	name(S,[C]).

char_int(C,C).

generate(Move,Farbe,Old,New,Hit):-
	all_moves(Farbe,Old,Move),
	make_move(Farbe,Old,Move,New,Hit).

%****************************************************************
%	Tree Management
%****************************************************************

newdepth(_Depth,hit,NewDepth) :-
	top(X),
	X<4,
	NewDepth=1,!.
newdepth(Depth,_,NewDepth) :-
	NewDepth is Depth-1,!.	

get_best(Stellung,Color,Depth,Alpha,Beta) :-
	invert(Color,Op),
	generate(Move,Color,Stellung,Neu_Stellung,Hit),
	newdepth(Depth,Hit,New_Depth),
	new_alpha_beta(Color,Alpha,New_Alpha,Beta,New_Beta),
	evaluate(Neu_Stellung,Op,Value,_,New_Depth,New_Alpha,New_Beta),
	compare_move(Move,Value,Color),
	cutting(Value,Color,Alpha,Beta),
	!,fail.
	
new_alpha_beta(white,Alpha,New_Alpha,Beta,Beta) :-
	get_0(_,Value),
	Value>Alpha,
	New_Alpha=Value,!.
new_alpha_beta(black,Alpha,Alpha,Beta,New_Beta) :-
	get_0(_,Value),
	Value<Beta,
	New_Beta=Value,!.
new_alpha_beta(_,Alpha,Alpha,Beta,Beta).
	
compare_move(_,Value,white) :-
	get_0(_,Old),
	Old>=Value,!.
compare_move(_,Value,black) :-
	get_0(_,Old),
	Old =< Value,!.
compare_move(Move,Value,_) :-
	replace(Move,Value).

cutting(Value,white,_,Beta) :-
	Beta<Value.
cutting(Value,black,Alpha,_) :-
	Alpha>Value.

evaluate(stellung(halbstellung(_,_,_,_,_,[],_),_,_),_,Value,move(0,0),_,_,_) :-
	winning(black,Value),!.
evaluate(stellung(_,halbstellung(_,_,_,_,_,[],_),_),_,Value,move(0,0),_,_,_) :-
	winning(white,Value),!.
evaluate(stellung(W,B,_),Color,Value,move(0,0),0,_,_) :-
	count_halbst(W,white,X),
	count_halbst(B,black,Y),
	compensate(Color,Z),
	Value is X-Y+Z,!.
evaluate(Stellung,Color,Value,Move,Depth,Alpha,Beta) :-
	worst_value(Color,Worst),
	push(move(0,0),Worst),
	not(get_best(Stellung,Color,Depth,Alpha,Beta)),
	pull(Move,Value),!.
	
%****************************************************************
%	Control Management
%****************************************************************

enter(Stellung,Color,Move) :-
	human(Color),
	repeat,
	read_move(Move),
	 (	check_legal(Move,Color,Stellung),
	 	nl,!
	 ;
	 	write('Illegal Move'),fail
	 ).


enter(Stellung,Color,Move) :-	
	depth(Depth),!,
	worst_value(white,Alpha),
	worst_value(black,Beta),
	evaluate(Stellung,Color,_Value,Move,Depth,Alpha,Beta),
	write_move(Move),!.
	
play(GrundStellung,Anzug) :-
	asserta(brett(GrundStellung,Anzug)),
	repeat,
	retract(brett(Stellung,Color)),
	  enter(Stellung,Color,Move),
	  make_move(Color,Stellung,Move,New,_),
	  invert(Color,Op),
	  asserta(brett(New,Op)),
	fail.
play(_,_).

	
%****************************************************************
%	Global Predicates
%****************************************************************

change(Old,Color,From,To,New):-
	half(Old,Halb,Color),
	exist(From,Halb,Typ),
	extract(Halb,Typ,Liste),
	remove(From,Liste,Templist),
	combine(Halb,Typ,[To|Templist],Newhalb),
	add_half(Old,Newhalb,Color,New).

kill(Old,Color,Feld,New):- 
	half(Old,Halb,Color),
	exist(Feld,Halb,Typ),
	extract(Halb,Typ,Liste),
	remove(Feld,Liste,Newlist),
	combine(Halb,Typ,Newlist,Newhalb),
	add_half(Old,Newhalb,Color,New).
	
extract(halbstellung(X,_,_,_,_,_,_),pawn,X).
extract(halbstellung(_,X,_,_,_,_,_),rook,X).
extract(halbstellung(_,_,X,_,_,_,_),knight,X).
extract(halbstellung(_,_,_,X,_,_,_),bishop,X).
extract(halbstellung(_,_,_,_,X,_,_),queen,X).
extract(halbstellung(_,_,_,_,_,X,_),king,X).

combine(halbstellung(_,B,C,D,E,F,G),pawn,N,halbstellung(N,B,C,D,E,F,G)).
combine(halbstellung(A,_,C,D,E,F,G),rook,N,halbstellung(A,N,C,D,E,F,G)).
combine(halbstellung(A,B,_,D,E,F,G),knight,N,halbstellung(A,B,N,D,E,F,G)).
combine(halbstellung(A,B,C,_,E,F,G),bishop,N,halbstellung(A,B,C,N,E,F,G)).
combine(halbstellung(A,B,C,D,_,F,G),queen,N,halbstellung(A,B,C,D,N,F,G)).
combine(halbstellung(A,B,C,D,E,_,G),king,N,halbstellung(A,B,C,D,E,N,G)).
	
%****************************************************************
%	MakeMove Routines
%****************************************************************

check_00(Old,white,15,17,New) :-
	Old=stellung(halbstellung(_,_,_,_,_,[15],_),_,_),
	change(Old,white,18,16,New),!.
check_00(Old,white,15,13,New) :-
	Old=stellung(halbstellung(_,_,_,_,_,[15],_),_,_),
	change(Old,white,11,14,New),!.
check_00(Old,black,85,87,New) :-
	Old=stellung(_,halbstellung(_,_,_,_,_,[85],_),_),
	change(Old,black,88,86,New),!.
check_00(Old,black,85,83,New) :-
	Old=stellung(_,halbstellung(_,_,_,_,_,[85],_),_),
	change(Old,black,81,84,New),!.
check_00(Old,_,_,_,Old).

make_move(Farbe,Old,move(From,To),New,hit):-
	invert(Farbe,Oppo),
	kill(Old,Oppo,To,Temp),
	change(Temp,Farbe,From,To,New),!.
make_move(Farbe,Old,move(From,To),New,nohit):-
	check_00(Old,Farbe,From,To,Temp),
	change(Temp,Farbe,From,To,New),!.

%****************************************************************
%	User Interface
%****************************************************************


read_move(move(From,To)):-
	repeat,
	  write('Your move: '),
	  read(Input),
	  (
	  	Input = 'exit',
	  	halt
	  ;
	        name(Input,[A,B,C,D]),
	  	str_pos([A,B],From),
	  	str_pos([C,D],To),!
	  ;
	  	write('Wrong format ( enter like <a1b2.> '),nl,
	  	fail
	  ).

str_pos([L,C],Pos):-
	nonvar(Pos),
	pos_no(Row,Col,Pos),
	L is Col + 96,
	C is Row + 48,!.
str_pos([L,C],Pos):-
	Col is L - 96,
	Row is C - 48,
	pos_no(Row,Col,Pos),!.

pos_no(Row,Col,N):-
	nonvar(N),!,
	Row is N // 10,
	Col is N mod 10.
pos_no(R,C,N):-
	N  is  R*10 + C.

check_legal(Move,Color,Stellung):-
 	generate(PosMove,Color,Stellung,_,_),
 	Move = PosMove,!.

write_move(move(From,To)):-
  	str_pos([A,B],From),
  	str_pos([C,D],To),
        name(Move,[A,B,C,D]),
	write('My move:   '),write(Move),nl,!.
	
who_vs_who:-
	write('Human(W) vs Human(B)      ( 1 )'),nl,
	write('Human(W) vs Computer(B)   ( 2 )'),nl,
	write('Computer(W) vs Human(B)   ( 3 )'),nl,
	write('Computer(W) vs Computer(B)( 4 )'),nl,
	get_vs(I),
	nl,
	write('Enter moves like <d2d4.>'),nl,
	write('Enter <exit.> to quit'),nl,
	nl,
	save_color(I).

	
get_vs(I):-
	get(CI),
	I is CI - 48,
	I > 0,I < 5,!.
get_vs(I):- get_vs(I).

save_color(1):-
	asserta(human(white)),
	assertz(human(black)),!.		
save_color(2):- asserta(human(white)),!.
save_color(3):- asserta(human(black)),!.	
save_color(4).
				
%****************************************************************
%	GOAL Section
%****************************************************************

grundstellung(stellung(H1,H2,0)):-
	Bauerw = [21,22,23,24,25,26,27,28],
	H1 = halbstellung(Bauerw,[11,18],[12,17],[13,16],[14],[15],notmoved),
	Bauerb = [71,72,73,74,75,76,77,78],
	H2 = halbstellung(Bauerb,[81,88],[82,87],[83,86],[84],[85],notmoved).

run:-
	retractall(stack(_,_,_)),
	retractall(top(_)),
	retractall(human(_)),
	retractall(depth(_)),
	retractall(brett(_,_)),

	grundstellung(Stellung),
	asserta(depth(2)),
	init_stack,
	who_vs_who,
	play(Stellung,white),
	closechess.	
			
%GOAL trace(off), run.

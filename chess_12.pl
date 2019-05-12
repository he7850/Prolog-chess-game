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
	get_best(position,color,i,i,i)
	new_alpha_beta(color,i,i,i,i)
	compare_move(move,i,color)
	cutting(i,color,i,i)
	evaluate(position,color,i,move,i,i,i)

	enter(position,color,move)
	play(position,color)
	initial_pos (position)
	change(position,color,i,i,position)
	kill(position,color,i,position)
	extract(half_position,type,list)
        combine(half_position,type,list,half_position)
	check_00(position,color,i,i,position)
	make_move(color,position,move,position,symbol)     
	generate(move,color,position,position,symbol)
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

generate(Move,Color,Old,New,Hit):-
	all_moves(Color,Old,Move),
	make_move(Color,Old,Move,New,Hit).

%****************************************************************
%	Tree Management
%****************************************************************

newdepth(_Depth,hit,NewDepth) :-
	top(X),
	X<4,
	NewDepth=1,!.
newdepth(Depth,_,NewDepth) :-
	NewDepth is Depth-1,!.	

get_best(Position,Color,Depth,Alpha,Beta) :-
	invert(Color,Op),
	generate(Move,Color,Position,New_Position,Hit),
	newdepth(Depth,Hit,New_Depth),
	new_alpha_beta(Color,Alpha,New_Alpha,Beta,New_Beta),
	evaluate(New_Position,Op,Value,_,New_Depth,New_Alpha,New_Beta),
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

evaluate(position(half_position(_,_,_,_,_,[],_),_,_),_,Value,move(0,0),_,_,_) :-
	winning(black,Value),!.
evaluate(position(_,half_position(_,_,_,_,_,[],_),_),_,Value,move(0,0),_,_,_) :-
	winning(white,Value),!.
evaluate(position(W,B,_),Color,Value,move(0,0),0,_,_) :-
	count_halfst(W,white,X),
	count_halfst(B,black,Y),
	compensate(Color,Z),
	Value is X-Y+Z,!.
evaluate(Position,Color,Value,Move,Depth,Alpha,Beta) :-
	worst_value(Color,Worst),
	push(move(0,0),Worst),
	not(get_best(Position,Color,Depth,Alpha,Beta)),
	pull(Move,Value),!.
	
%****************************************************************
%	Control Management
%****************************************************************

enter(Position,Color,Move) :-
	human(Color),
	repeat,
	read_move(Move),
	 (	check_legal(Move,Color,Position),
	 	nl,!
	 ;
	 	write('Illegal Move'),fail
	 ).


enter(Position,Color,Move) :-	
	depth(Depth),!,
	worst_value(white,Alpha),
	worst_value(black,Beta),
	evaluate(Position,Color,_Value,Move,Depth,Alpha,Beta),
	write_move(Move),!.
	
play(BasicPosition,Start) :-
	asserta(board(BasicPosition,Start)),
	repeat,
	retract(board(Position,Color)),
	enter(Position,Color,Move),
	make_move(Color,Position,Move,New,_),
	invert(Color,Op),
	asserta(board(New,Op)),
	fail.
play(_,_).

	
%****************************************************************
%	Global Predicates
%****************************************************************

change(Old,Color,From,To,New):-
	half(Old,Half,Color),
	exist(From,Half,Type),
	extract(Half,Type,List),
	remove(From,List,Templist),
	combine(Half,Type,[To|Templist],Newhalf),
	add_half(Old,Newhalf,Color,New).

kill(Old,Color,Feld,New):- 
	half(Old,Half,Color),
	exist(Feld,Half,Type),
	extract(Half,Type,List),
	remove(Feld,List,Newlist),
	combine(Half,Type,Newlist,Newhalf),
	add_half(Old,Newhalf,Color,New).
	
extract(half_position(X,_,_,_,_,_,_),pawn,X).
extract(half_position(_,X,_,_,_,_,_),rook,X).
extract(half_position(_,_,X,_,_,_,_),knight,X).
extract(half_position(_,_,_,X,_,_,_),bishop,X).
extract(half_position(_,_,_,_,X,_,_),queen,X).
extract(half_position(_,_,_,_,_,X,_),king,X).

combine(half_position(_,B,C,D,E,F,G),pawn,N,half_position(N,B,C,D,E,F,G)).
combine(half_position(A,_,C,D,E,F,G),rook,N,half_position(A,N,C,D,E,F,G)).
combine(half_position(A,B,_,D,E,F,G),knight,N,half_position(A,B,N,D,E,F,G)).
combine(half_position(A,B,C,_,E,F,G),bishop,N,half_position(A,B,C,N,E,F,G)).
combine(half_position(A,B,C,D,_,F,G),queen,N,half_position(A,B,C,D,N,F,G)).
combine(half_position(A,B,C,D,E,_,G),king,N,half_position(A,B,C,D,E,N,G)).
	
%****************************************************************
%	MakeMove Routines
%****************************************************************

check_00(Old,white,15,17,New) :-
	Old=position(half_position(_,_,_,_,_,[15],_),_,_),
	change(Old,white,18,16,New),!.
check_00(Old,white,15,13,New) :-
	Old=position(half_position(_,_,_,_,_,[15],_),_,_),
	change(Old,white,11,14,New),!.
check_00(Old,black,85,87,New) :-
	Old=position(_,half_position(_,_,_,_,_,[85],_),_),
	change(Old,black,88,86,New),!.
check_00(Old,black,85,83,New) :-
	Old=position(_,half_position(_,_,_,_,_,[85],_),_),
	change(Old,black,81,84,New),!.
check_00(Old,_,_,_,Old).

make_move(Color,Old,move(From,To),New,hit):-
	invert(Color,Oppo),
	kill(Old,Oppo,To,Temp),
	change(Temp,Color,From,To,New),!.
make_move(Color,Old,move(From,To),New,nohit):-
	check_00(Old,Color,From,To,Temp),
	change(Temp,Color,From,To,New),!.

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

check_legal(Move,Color,Position):-
 	generate(PosMove,Color,Position,_,_),
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

initial_pos(position(H1,H2,0)):-
	PawnWhite = [21,22,23,24,25,26,27,28],
	H1 = half_position(PawnWhite,[11,18],[12,17],[13,16],[14],[15],notmoved),
	PawnBlack = [71,72,73,74,75,76,77,78],
	H2 = half_position(PawnBlack,[81,88],[82,87],[83,86],[84],[85],notmoved).

run:-
	retractall(stack(_,_,_)),
	retractall(top(_)),
	retractall(human(_)),
	retractall(depth(_)),
	retractall(board(_,_)),

	initial_pos(Position),
	asserta(depth(2)),
	init_stack,
	who_vs_who,
	play(Position,white),
	closechess.	
			
%GOAL trace(off), run.

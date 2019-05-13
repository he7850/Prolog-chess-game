%	
% Position Evaluation
%

compensate(white,15).
compensate(black,-15).
	
worst_value(white,-10000).
worst_value(black, 10000).

winning(white, 9000).
winning(black,-9000).	
		
count_halfst(half_position(Pawns,Rooks,Knights,Bishops,Queens,[_],_)
						,Color,Value) :-				
	pos_count(pawn,Pawns,Color,V1),
	pos_count(rook,Rooks,Color,V2),
	pos_count(bishop,Bishops,Color,V3),
	pos_count(knight,Knights,Color,V4),
	pos_count(queen,Queens,Color,V5),
	double_bonus(Rooks,D1),
	double_bonus(Knights,D2),
	double_bonus(Bishops,D3),
	Value is V1+V2+V3+V4+V5+30*(D1+D2+D3).

double_bonus([_,_],1) :- !.
double_bonus(_,0).

pos_count(_,[],_,0) :- !.
pos_count(Type,[Feld|Rest],Color,Value) :-
	pos_count(Type,Rest,Color,V2),
	pos_value(Type,Feld,Color,V1),	
	Value is V1+V2,!.
		
pos_value(Type,Feld,black,Value) :-
	Rel_Feld is 99-Feld,
	pos_value(Type,Rel_Feld,white,Value),!.   

pos_value(Type,Pos,white,Value) :-
	row(Pos,Row),
	member(Type,[bishop,queen]),
	row_value(Type,Row,Value),!.
pos_value(pawn,Pos,white,127) :-
	member(Pos,[34,35]),!.
pos_value(pawn,Pos,white,131) :-
	member(Pos,[44,45,54,55]),!.
pos_value(pawn,_,white,100) :- !.
pos_value(king,Pos,white,30) :-
	member(Pos,[11,12,13,17,18]),!.
pos_value(rook,_,white,450) :- !.
pos_value(Type,Pos,white,Value) :-
	Type=knight,
	row_line(Pos,Row,Line),
	row_value(Type,Row,V1),
	line_value(Type,Line,V2),
	Value is V1+V2,!.

row_value(knight,2,320) :- !.
row_value(knight,3,321) :- !.
row_value(knight,X,348) :-
	member(X,[4,5]),!.
row_value(knight,X,376) :-
	member(X,[6,7]),!.
row_value(knight,_,290) :- !.
row_value(bishop,1,300) :- !.
row_value(bishop,X,329) :-
	member(X,[2,3]),!.
row_value(bishop,_,330) :- !.
row_value(queen,1,850) :- !.
row_value(queen,_,876) :- !.

line_value(knight,X,0) :-
	member(X,[1,8]),!.
line_value(knight,_,10) :- !.	

row(Pos,Row) :-
	Row is Pos // 10.
row_line(Pos,Row,Line) :-
	Row is Pos // 10,
	Line is Pos mod 10.


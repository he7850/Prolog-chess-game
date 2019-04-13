# Prolog-chess-game

### Team Members: Bin Hu (bxh171130) & Marcus Chiu (mxc123530)

### Project Idea: Prolog Chess Game
### Outline of Project 
- Interactive game between: 
  - Human v computer
  - Computer v computer
  - Human v human
- Choosing which player goes first

### Game Flow
Each side takes turns (either Human and/or Computer)
After each turn/move, check board state

### Human Turn
- Ask for input
- Sanitize and validate the input which basically makes sure the input is a legal move
  - Queen - can only move horizontally, vertically, diagonally
  - Knight - moves in L shapes
  - Rook - moves horizontally and vertically
  - Bishop - moves diagonally
  - King - can move in any neighboring square 
  - Pawn - can only move forward 1 space, or 2 spaces for the first move during game
  - All resultings moves should be within the board space
  - All moves should have a open path with no pieces between starting position and ending position (except for knights)
- Then it executes the move onto to board state

### Computer Turn
- Given the current board state search all possible moves and calculate its corresponding score
- Decide the best move based on the score
- Then it executes the move onto to board state

### Check Board State
- Not End State
- End State
  - Win Condition - obvious states
  - Lose Condition - obvious states
  - Tie Condition
    - King is not in checkmate and there are no legal moves to the current player
    - If the last 3 moves of each player are the “same”, then tie

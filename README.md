This project is part of the course "Ruby" by The Odin Project. 
Check it out at: 

The project is written in Ruby and Rspec is used for testing. 
The game is played on the console. 

Pseudo code: 
- Display instruction
- Ask if player wants to continue with the last game (if there is any)
    + If yes, deserialize the last version 
    + If no, continue
- Loop do 
    - Display chess board 
    - Check & display result if game is over
        + If it is over (win or tie) display result
        + If no, continue
    - Ask if player wants to quit the game and save it
        + If yes, serialize it 
        + If no, continue
    - Loop do 
        + Ask for player's move & Check typo 
        + Tranform if typo is correct
        + Check if the piece exist
            + if yes, return the piece
            + if no, return nil
        + Check if destination is occupied by player's other pieces
        + Check valid piece's pattern 
            - special move
            - normal move
                +eat
                +not eat
        + Check obstacles between current location and destination 
        + Save the current state of the board
        + Move the piece 
        + Check if player's king is being checked after the move 
            - if yes, restore the original state
            - if no, keep going 
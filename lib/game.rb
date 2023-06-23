require "require_all"
require_all './lib/pieces'
require_all "./lib/*.rb"

class Game 
    include BasicSerialize
    attr_accessor :white, :black, :board, :count, :in_passing, :removed_piece
    def initialize
        @white = Player.new('w')
        @black = Player.new('b')
        @board = Board.new
        @count = 0
        @in_passing = nil
        @removed_piece = nil
    end
    def play 
        if introduce == 'c' 
            unserialize 
        else 
            @white.pieces = @white.create_new_pieces
            @black.pieces = @black.create_new_pieces
        end
        set_up 
        loop do 
            board.display 
            player = count.even? ? @white : @black
            opponent = count.even? ? @black : @white
            return if count % 3 == 0 && serialize?
            
            loop do 
                move = get_move(player) #[piece, postion, destination]
                next if move.nil?
                piece = move[0]
                position = move[1]
                destination = move[2]
                if piece.name == 'K'
                    next if is_eaten_by(opponent.pieces, destination).length > 0
                    if piece.path_valid?(board, destination)
                        change(piece, position, destination, opponent)
                        piece.castle = false
                    else 
                        next unless player.check_castle? && castle_succeed?(player, piece, destination, opponent)
                    end
                else  
                    player_king_coor = player.get_piece('K')[0].position
                    if piece.name == 'p'
                        pawn_move = pawn_valid_move(piece, position, destination, opponent)
                        next unless pawn_move
                        change(piece, position, destination, opponent, pawn_move)
                        if is_eaten_by(opponent.pieces, player_king_coor).length > 0    
                            undo(piece, position, destination, opponent)
                            next
                        end
                        pawn_promote(player, piece)
                    else 
                        next unless piece.path_valid?(board, destination)
                        piece.castle = false if piece.name == 'R'
                        change(piece, position, destination, opponent)      
                        if is_eaten_by(opponent.pieces, player_king_coor).length > 0
                            undo(piece, position, destination, opponent)
                            next
                        end
                    end                            
                end
                break
            end
            modify_in_passing(player)
            result = is_checkmated?(player, opponent)
            result = tie?(player, opponent) unless result 
            if result != false
                annouce_result(result)
                board.display
                break
            end
            @count += 1 
        end
    end
    def annouce_result(result)
        case result
        when "tie" 
            puts "You tie!"
        else 
            puts "Congratulation #{result}, you win the game!"
        end
    end
    def serialize?
        case ask_for_serialization
        when 'x'
            obj = {}
            obj[:@white] = @white.serialize
            obj[:@black] = @black.serialize
            obj[:@count] = @count
            @in_passing.nil? ? obj[:@in_passing] = nil : obj[:@in_passing] = @in_passing.serialize
            @removed_piece.nil? ? obj[:@removed_piece] = nil : obj[:@removed_piece] = @removed_piece.serialize
            File.open('./lib/saved_game.yml', 'w') {|file| file.puts @@serializer.dump obj}
            true 
        else 
            false
        end
    end

    def unserialize
        obj = @@serializer.load(File.read('./lib/saved_game.yml'))
        @count = obj[:@count]
        @white.unserialize(obj[:@white])
        @black.unserialize(obj[:@black])
        
        if obj[:@in_passing].nil?
            @in_passing = nil 
        else 
            @in_passing = piece_unserialize(obj[:@in_passing])
        end

        if obj[:@removed_piece].nil?
            @removed_piece = nil 
        else 
            @removed_piece = piece_unserialize(obj[:@removed_piece])
        end
        
    end
    def ask_for_serialization
        loop do 
            puts "Press 'c' if you want to continue the game and 'x' if you want to exit and save it"
            answer = gets.chomp.strip
            return answer if answer == 'c' || answer == 'x'
            puts 'invalid answer! Please enter a proper one'
        end
    end
    def set_up 
        board.create_board
        [@white, @black].each do |player|
            player.pieces.each do |piece|
                board.change_status(piece.position, piece)
            end
        end
    end
    def undo(piece, position, destination, opponent) 
        piece.position = position
        board.change_status(position, piece)
        board.change_status(destination, nil)
        @in_passing = nil if @in_passing == piece
        unless @removed_piece.nil?
            opponent.pieces << @removed_piece
            board.change_status(@removed_piece.position, @removed_piece)
            @removed_piece = nil
        end
    end
    def pawn_promote(player, piece)
        piece_name = piece.promote?
        unless piece_name.nil?
            player.pieces.delete(piece) 
            new_piece = player.promote(piece_name, piece.position) 
            board.change_status(new_piece.position, new_piece)
        end
    end
    def modify_in_passing(player)
        @in_passing = nil if in_passing != nil && in_passing.color != player.color
    end

    def is_eaten_by(attack, defense_coor)
        result = []
        attack.each do |piece|
            
            if piece.name == 'p' 
                result << piece if piece.eat?(defense_coor)
            else 
                result << piece if piece.path_valid?(board, defense_coor)
            end
        end
        result
    end
    def tie?(attack, defense)
        #king is not checked 
        defense_king = defense.get_piece('K')[0]
        return false if is_eaten_by(attack.pieces, defense_king.position).length > 0
        #king has no way to go 
        defense_king.generate_possible_coors.each do |destination|
            return false if is_eaten_by(attack.pieces, destination).length == 0
        end
        #other pieces have no way to go
        other_pieces = defense.pieces.select {|piece| piece.name != 'K'}
        other_pieces.each do |piece|
            adjacent_coors = piece.generate_possible_coors
            adjacent_coors.each do |destination|
                if pass_basic_condition(defense, destination)
                    if piece.name == 'p'
                        return false if pawn_valid_move(piece, piece.position, destination, attack) 
                    end
                    return false
                end
            end
        end
        'tie'
    end
    def is_checkmated?(attack, defense)
        defense_king = defense.get_piece('K')[0]
        
        attack_pieces = is_eaten_by(attack.pieces, defense_king.position)
        case attack_pieces.length 
        when 0
            return false
        when 1
           
            #if we can eat the attack_piece
            attack_piece = attack_pieces[0]
            defense_pieces = defense.pieces.select {|piece| piece.name != 'K'}
            return false if is_eaten_by(defense_pieces, attack_piece.position).length > 0
            #if we can shield the king by another piece
            unless attack_piece.name == 'N' || attack_piece.name == 'p'
                coor_between = attack_piece.coor_between(defense_king.position)
                defense_pieces = defense.pieces.select {|piece| piece.name != 'K'}
                coor_between.each do |destination|
                    defense_pieces.each do |piece|
                        if piece.name == 'p' 
                            return false if pawn_valid_move(piece, piece.position, destination, attack) != false
                            
                        else   
                            return false if piece.path_valid?(board, destination) 
                        end
                    end
                end
            end
        end
        #if the king can run on its own
        defense_king.generate_possible_coors.each do |destination|
            next if board.get_status_color(destination) == defense.color
            return false if is_eaten_by(attack.pieces, destination).length == 0
        end
        attack.color
    end
    
    def pawn_valid_move(piece, position, destination, opponent)
        direction = piece.get_direction(destination)
        return false unless piece.move_pattern?(direction)
        if [[0,1], [0,-1]].any?(direction) 
            board.get_status(destination).nil?
        elsif [[0,2], [0,-2]].any?(direction)
            return false unless board.get_status(destination).nil?
            return false unless piece.initial_position?
            if piece.color == 'w' 
                obstacle_coordinator = [position[0], position[1]+1]
            else 
                obstacle_coordinator = [position[0], position[1]-1]
            end

            return false unless board.get_status(obstacle_coordinator).nil? 
            #send signal to turn on in-passing
            piece
        else 
            if board.get_status(destination).nil?
                return false if @in_passing.nil?
                opponent_pawn = opponent.get_piece('p', [position[0] + direction[0], position[1]])
                #send signal to eat the "in-passing" piece 
                @in_passing == opponent_pawn ? opponent_pawn : false
            else true end
        end 
    end
    def castle_succeed?(player, piece, destination, opponent)
        return false if is_eaten_by(opponent, piece.position)
        if player.color == 'w' 
            case destination
            when [7,1]
                middle_square_coordinator = [[6,1], [7,1]]
                rook = player.get_piece('R', [8,1])
            when [3,1]
                rook = player.get_piece('R', [1,1])
                middle_square_coordinator = [[2,1],[3,1],[4,1]]
            else  
                return false
            end
        else 
            case destination
            when [7,8]
                rook = player.get_piece('R', [8,8])
                middle_square_coordinator = [[6,8], [7,8]]
            when [3,8]
                rook = player.get_piece('R', [1,8])
                middle_square_coordinator = [[2,8],[3,8],[4,8]]
            else  
                return false
            end
        end
        if middle_square_coordinator.map {|coor| board.get_status(coor) }.all?(nil)
            castling(piece, rook, destination)
            piece.castle = false
            true
        else 
            false 
        end
    end
    def castling(king, rook, destination) 
        #change previous square status
        board.change_status(king.position, nil)
        board.change_status(rook.position, nil)
        #change rook and king position
        direction = destination[0] - king.position[0]
        if king.color == 'w' 
            direction > 0 ? rook.position = [6,1] : rook.position = [4,1]
        else 
            direction > 0 ? rook.position = [6,8] : rook.position = [4,8]
        end
        king.position = destination
        #change current square status
        board.change_status(king.position, king)
        board.change_status(rook.position, rook)
    end
    
    def change(piece, position, destination, opponent, pawn_move=nil)
        if pawn_move.instance_of? Pawn
            case pawn_move.color
            when piece.color
                @in_passing = piece
            else 
                @removed_piece = opponent.pieces.delete(pawn_move)
                board.change_status(pawn_move.position, nil)
            end
        end
        
        @removed_piece = opponent.pieces.delete(board.get_status(destination)) 
        piece.position = destination
        board.change_status(position, nil) 
        board.change_status(destination, piece) 
    end
    def get_move(player)
        move_raw = ask(player)
        return unless move_raw.length == 5 || move_raw.length == 7
        pieces_names = ['K','Q','R','B','N']
        piece_name_arr = move_raw.intersection(pieces_names)
        if piece_name_arr.length == 0 
            piece_name = 'p'
        elsif piece_name_arr.length == 1 
            piece_name = piece_name_arr[0]
        else 
            return 
        end
        move_raw.delete(piece_name)
        return unless move_raw.length == 5
        position = move_raw[0..1]
        destination = move_raw[-2..-1]
        if position[0].between?('a','h') && destination[0].between?('a','h') &&
            position[1].between?('1','8') && destination[1].between?('1','8')
            position = transform_coordinator(position)
            destination = transform_coordinator(destination)
        else 
            return 
        end
        piece = player.get_piece(piece_name, position)
        return if piece.nil?
        return [piece, position, destination] if pass_basic_condition(player, destination)

    end
    def pass_basic_condition(player, destination)
        board.get_status(destination).nil? || board.get_status_color(destination) != player.color  
    end
    def transform_coordinator(raw_coordinator)
        x = raw_coordinator[0].ord - 96
        [x, raw_coordinator[1].to_i]
    end

    def ask(player)
        puts "player #{player.color} please make a valid move"
        gets.chomp.strip.split('')
    end
    def introduce
        puts 'Welcome to the game!'
        unless File.zero?('./lib/saved_game.yml')
            loop do 
                puts "Press 'n' if you want to play new game and 'c' if you want to continue previous game"
                answer = gets.chomp.strip
                return answer if answer == 'n' || answer == 'c'
                puts "Please enter a valid answer!"
            end
        end
    end
end
new_game = Game.new
test = new_game.play
 


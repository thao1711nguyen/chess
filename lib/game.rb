require_relative './board.rb'
class Game 
    attr_accessor :board
    def initialize
        @board = nil
        @board_serialize = nil
        @count = 0
    end
    def ask(player)
        puts "Player #{player} please make a valid move"
        puts "The correct format is: [piece][current location]-[piece][destination] for all the pieces, except for pawn"
        puts "For example: to move a queen: Qa1-Qa8"
        puts "In case of a pawn: [current location]-[destination]. For example: b2-b3 "
        gets.chomp.strip.split('')
    end
    def get_move(player)
        move_raw = ask(player)
        condition1 = -> (char) { char.between?('a', 'h') }
        condition2 = -> (char) { char.between?('1', '8') }
        condition3 = -> (char) { ['K','Q','R','B','N'].include?(char) }
        if move_raw.length == 5
            if move_raw[move_raw.length/2] == "-" &&  
                condition1.call(move_raw[0]) && condition2.call(move_raw[1]) &&
                condition1.call(move_raw[3]) && condition2.call(move_raw[4])
                move_raw
            end
        elsif move_raw.length == 7 
            if move_raw[move_raw.length/2] == "-" && 
                condition3.call(move_raw[0]) && condition3.call(move_raw[4]) &&
                move_raw[0] == move_raw[4] &&
                condition1.call(move_raw[1]) && condition2.call(move_raw[2]) &&
                condition1.call(move_raw[5]) && condition2.call(move_raw[6])
                move_raw
            end
        end  
    end
    def transform(raw_move)
        convert = -> (char) { char.ord - 96 }
        if raw_move.length == 5
            x1 = convert.call(raw_move[0])
            y1 = raw_move[1].to_i
            x2 = convert.call(raw_move[3])
            y2 = raw_move[4].to_i
            { piece: 'p', current: [x1, y1], destination: [x2, y2]}
        else 
            x1 = convert.call(raw_move[1])
            y1 = raw_move[2].to_i
            x2 = convert.call(raw_move[5])
            y2 = raw_move[6].to_i
            { piece: raw_move[0], current: [x1, y1], destination: [x2, y2]}
        end
    end
    def convert_pattern(move)
        x = move[:destination].coordinator[0] - move[:current].coordinator[0]
        y = move[:destination].coordinator[1] - move[:current].coordinator[1]
        pattern = [x,y]
        if ["p", "K", "N"].include?(move[:current].status.name)
            return pattern
        end
        not_zero = pattern.detect {|n| n!= 0}.abs.to_f
        pattern.map {|n| n/not_zero }
    end
    def get_path(player, opponent, piece, move) 
        pattern = convert_pattern(move)
        
        result = special_pattern(player, opponent, move, piece, pattern) 
        return result unless result.nil?
        if piece.name == 'p'
            if piece.normal_pattern.include?(pattern) && move[:destination].status.nil?
                return 'normal'
            end 
            if piece.eat_pattern.include?(pattern)
                return 'normal' if !move[:destination].status.nil? && move[:destination].status.color == opponent
            end
        else 
            'normal' if piece.normal_pattern.include?(pattern) && !@board.obstacle?(move[:current].coordinator, move[:destination].coordinator, pattern)
        end
    end
    def in_passing?(pattern, piece, move)
        destination = move[:destination].coordinator
        eat_coor = case piece.color 
        when 'w'
            [destination[0], destination[1]-1]
        when 'b'
            [destination[0], destination[1]+1]
        end
        eat_square = @board.square(eat_coor)
        piece.eat_pattern.include?(pattern) && !eat_square.status.nil? && 
            eat_square.status.name == 'p' &&
            eat_square.status.in_passing
    end
    def castle?(player, opponent, move, king)
        king_square = move[:current]
        pattern = convert_pattern(move)
        return unless king.special_pattern.include?(pattern)
        rook_coor = case move[:destination].coordinator
        when [7,1]
            [8,1]
        when [3,1]
            [1,1]
        when [7,8]
            [8,8]
        when [3,8]
            [1,8]
        end
        rook = @board.get_piece('R', rook_coor, player)
        return if !king.castle || rook.nil? || !rook.castle

        return if @board.pieces(opponent).any? { |square| can_eat?(square, king_square) }

        rook_square = @board.square(rook_coor)
        unless @board.obstacle?(rook_coor, move[:current].coordinator, convert_pattern({current: rook_square, destination: king_square}))
            rook 
        end
    end
    
    def can_eat?(attack, defense)
        pattern = convert_pattern({current: attack, destination: defense})
        return false unless attack.status.eat_pattern.include?(pattern)
        !@board.obstacle?(attack.coordinator, defense.coordinator, pattern)
         
    end
    #not tested yet
    def initial_pattern(piece, move, pattern)
        obstacle_pattern = piece.color == 'w' ? [0,1] : [0,-1]
        piece.initial_position?(move[:current].coordinator) &&
            piece.special_pattern.include?(pattern) &&
            !@board.obstacle?(move[:current].coordinator, move[:destination].coordinator, obstacle_pattern)
    end
    def last_pattern(piece, move, pattern)
        return unless piece.final_position?(move[:destination].coordinator)
        if piece.normal_pattern.include?(pattern)
            if @board.square(move[:destination].coordinator).status.nil?
                return true
            end
        end
        if piece.eat_pattern.include?(pattern)
            if (!@board.square(move[:destination].coordinator).status.nil? && @board.square(move[:destination].coordinator).status.color != piece.color)
                
                true  
            end
        
        end
    end
    def special_pattern(player, opponent, move, piece, pattern) 
        if piece.name == "K"
            castle?(player, opponent, move, piece)
        elsif piece.name == 'p'
            return 'pawn first' if initial_pattern(piece, move, pattern)
            return 'pawn last' if last_pattern(piece, move, pattern)
            'in-passing' if in_passing?(pattern, piece, move)
        end
    end
    def save_state
        @board_serialize = Marshal.dump(@board)
    end
    def undo 
        @board = Marshal.load(@board_serialize)
    end
    def normal_moving(piece, move)
        move[:current].status = nil 
        move[:destination].status = piece
        case piece.name 
        when 'K'
            piece.castle = false
        when 'R'
            piece.castle = false 
        end
    end
    def castle_moving(king, rook, move)
        king.castle = false 
        rook.castle = false
        normal_moving(king, move)
        rook_coor = nil 
        old_rook = nil
        case move[:destination].coordinator 
        when [7,1]
            rook_coor = [6,1]
            old_rook = [8,1]
        when [3,1] 
            rook_coor = [4,1]
            old_rook = [1,1]
        when [7,8] 
            rook_coor = [6,8]
            old_rook = [8,8]
        when [3,8]
            rook_coor = [4,8]
            old_rook = [1,8]
        end
        @board.square(rook_coor).status = rook
        @board.square(old_rook).status = nil
    end
    def promote(move, piece)
        move[:current].status = nil
        new_piece = get_new_piece(move[:destination].coordinator, piece.color)
        move[:destination].status = new_piece
    end
    def get_new_piece(coordinator, color)
        pieces_names = ['Q', 'R', 'B', 'N']
        piece_name = nil 
        loop do 
            puts "Which piece would you like your pawn to become? "
            puts "Queen(Q), Rook(R), Bishop(B) or Knight(N)"
            piece_name = gets.chomp.strip
            break if pieces_names.any?(piece_name)
            puts "Please enter a valid piece!"
        end
        case piece_name 
        when 'Q'
            Queen.new(color)
        when 'R'
            Rook.new(color)
        when 'B'
            Bishop.new(color)
        when 'N'
            Knight.new(color)
        end
        
    end
    def in_passing_moving(move, piece)
        destination = move[:destination].coordinator
        eat_coor = case piece.color 
        when 'w'
            [destination[0], destination[1]-1]
        when 'b'
            [destination[0], destination[1]+1]
        end
        normal_moving(piece, move)
        @board.square(eat_coor).status = nil
    end
    def moving(path, piece, move)
        @board.remove_in_passing
        if path == 'normal'
            normal_moving(piece, move)
        elsif path.instance_of? Rook
            castle_moving(piece, path, move)
        elsif path == 'pawn first'
            normal_moving(piece, move)
            piece.in_passing = true
        elsif path == 'pawn last'
            promote(move, piece)
        elsif path == 'in-passing'
            in_passing_moving(move, piece)
        end
    end
    def tie?(attack, defense)
        # defense: king & attack: king + knight || bishop 
        attack_pieces = @board.pieces(attack).map {|square| square.status.name }
        player_pieces = @board.pieces(defense).map {|square| square.status.name }
        condition1 = player_pieces.length == 1 &&
                        attack_pieces.length == 2 && 
                        (attack_pieces.include?('N') || attack_pieces.include?('B')) 
        return true if condition1
        #king is not checked 
        king_square = @board.get_king(defense)
        king_checked = @board.pieces(attack).any? do |att|
            can_eat?(att, king_square) 
        end
        return false if king_checked
        #king & other pieces have no way to go
        !@board.pieces(defense).any? do |square|
            piece = square.status

            all_patterns = (piece.normal_pattern + piece.eat_pattern).uniq
            if piece.name == 'K' || piece.name == 'p'
                all_patterns = all_patterns + piece.special_pattern
            end

            all_patterns.any? do |pat|
                x = square.coordinator[0] + pat[0]
                y = square.coordinator[1] + pat[1]
                ajacent_square = @board.square([x,y])

                condition1 = !ajacent_square.nil? && (ajacent_square.status.nil? || ajacent_square.status.color != 'defense') && 
                    !@board.obstacle?(square.coordinator, [x,y], pat) &&
                    get_path(defense, attack, piece, {current: square, destination: ajacent_square})
                
                condition2 = true
                
                if condition1 && piece.name == 'K'
                    condition2 = @board.pieces(attack).all? {|att| !can_eat?(att, ajacent_square) } 
                end
                condition1 && condition2
            end
        end
        
            
    end
    def is_checkmated?(attack, defense)
        king_square = @board.get_king(defense)
        king = king_square.status
        #king is checked
        king_checked = @board.pieces(attack).any? {|att| can_eat?(att, king_square) }
        return false unless king_checked
        #the king can't run on its own
        king_patterns = (king.normal_pattern + king.eat_pattern + king.special_pattern).uniq
        king_run = king_patterns.any? do |pat| 
            x = king_square.coordinator[0] + pat[0]
            y = king_square.coordinator[1] + pat[1]
            ajacent_square = @board.square([x,y])
            !ajacent_square.nil? && 
                (ajacent_square.status.nil? || ajacent_square.status.color != defense) &&
                !@board.obstacle?(king_square.coordinator, [x,y], pat) &&
                get_path(defense, attack, king, {current: king_square, destination: ajacent_square}) &&
                @board.pieces(attack).all? {|att| !can_eat?(att, ajacent_square) }
        end
        return false if king_run

        #we can't eat the attack_piece || there are more than 1 piece is checking
        #we can't shield the king by another piece || there are more than 1 piece is checking
        checking_squares = @board.pieces(attack).select {|att|  can_eat?(att, king_square) }
        return true if checking_squares.length > 1

        defense_pieces = @board.pieces(defense).select {|square| square.status.name != 'K'}
        return false if defense_pieces.any? {|square| can_eat?(square, checking_squares[0]) }
        

        step = checking_squares[0].coordinator.dup
        check_patten = convert_pattern({current: checking_squares[0], destination: king_square})
        loop do 
            step[0] += check_patten[0]
            step[1] += check_patten[1]
            return true if step == king_square.coordinator
            step_square = @board.square(step)
            valid_shield = @board.pieces(defense).any? do |square|
                pattern = convert_pattern({current: square, destination: step_square})
                get_path(defense, attack, square.status, {current: square, destination: step_square}) &&
                    !@board.obstacle?(square.coordinator, step, pattern)
            end
            return false if valid_shield
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
    # in-progress
    def serialize?
        case ask_for_serialization
        when 'x'
            object = {board: @board, count: @count}
            File.open('./lib/saved_game.yml', 'w') {|file| file.puts Marshal.dump object}
            true 
        else 
            false
        end
    end

    def unserialize
        object = Marshal.load(File.read('./lib/saved_game.yml'))
        @board = object[:board]
        @count = object[:count]
    end
    def introduce
        puts 'Welcome to the game!'
        if File.exist?('./lib/saved_game.yml')
            loop do 
                puts "Press 'n' if you want to play new game and 'c' if you want to continue previous game"
                answer = gets.chomp.strip
                return answer if answer == 'n' || answer == 'c'
                puts "Please enter a valid answer!"
            end
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
    def delete_file
        if File.exist?('./lib/saved_game.yml')
            File.delete('./lib/saved_game.yml')
        end
    end
    def play 
        if introduce == 'c'
            unserialize
        else 
            @board = Board.new
        end
        loop do 
            @board.display
            player = @count % 2 == 0 ? 'w' : 'b'
            opponent = player == 'w' ? 'b' : 'w'
            if tie?(opponent, player) 
                annouce_result('tie')
                delete_file
                return
            end
            if is_checkmated?(opponent, player)
                annouce_result(opponent)
                delete_file
                return
            else 
                return if serialize?
            end
            loop do 
                raw_move = get_move(player)
                next if raw_move.nil? 
                move = transform(raw_move)
                piece = @board.get_piece(move[:piece], move[:current], player)
                if piece
                    move = {current: @board.square(move[:current]), destination: @board.square(move[:destination]) }
                else 
                    next 
                end
                next if !move[:destination].status.nil? && move[:destination].status.color == player
                path = get_path(player, opponent, piece, move)
                next if path.nil?
                save_state
                moving(path, piece, move)
                
                player_king = @board.get_king(player)
                opponent_pieces = @board.pieces(opponent).map {|square| square.status.name }
                king_checked = @board.pieces(opponent).any? do |square| 
                    can_eat?(square, player_king)
                end
                if king_checked
                    undo 
                    next
                else 
                    @count +=1
                    break
                end
            end
        end
    end
end

new_game = Game.new 
new_game.play
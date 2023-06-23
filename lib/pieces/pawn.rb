require_relative "serialize.rb"
require_relative "knight.rb"
class Pawn < Knight
    include BasicSerialize
    attr_reader :color, :name
    attr_accessor :position, :two_steps, :in_passing
    def initialize(coordinator, color)
        @position = coordinator
        @color = color
        @name = 'p'
        @symbol = color == 'w' ? "\u2659" : "\u265F"
    end

    def initial_position?
        if color == "w"
            initial_positions = (1..8).to_a.product([2])
        else 
            initial_positions = (1..8).to_a.product([7])
        end
        initial_positions.any?(position) 
    end
    def final_position?
        if color == "w"
            final_positions = (1..8).to_a.product([8])
        else 
            final_positions = (1..8).to_a.product([1])
        end
        final_positions.any?(position) 
    end
    
    def get_direction(destination)
        direction = []
        destination.each_with_index do |coor, idx|
            direction[idx] = coor - position[idx]
        end
        direction
    end
    def eat?(destination)
        direction = get_direction(destination)
        if color == 'w'
            [[-1,1], [1,1]].any?(direction) 
        else 
            [[-1,-1], [1,-1]].any?(direction) 
        end
    end
    def promote?
        return unless final_position?
        pieces_names = ['Q', 'R', 'B', 'N']
        loop do 
            puts "Which piece would you like your pawn to become? "
            puts "Queen(Q), Rook(R), Bishop(B) or Knight(N)"
            piece_name = gets.chomp.strip
            return piece_name if pieces_names.any?(piece_name)
            puts "Please enter a valid piece!"
        end
    end
    
    def move_pattern?(direction)
        move_pattern.any?(direction)
    end
    
    private
    def move_pattern
        if @color == 'w'
            [[0,2], [0,1], [-1,1], [1,1]]
        else 
            [[0,-2], [0,-1], [-1,-1], [1, -1]]
        end
    end
end
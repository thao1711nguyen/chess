require_relative 'serialize.rb'
class Knight
    include BasicSerialize
    attr_accessor :position
    attr_reader :name, :symbol, :color
    def initialize(coordinator, color)
        @position = coordinator
        @color = color
        @name = 'N'
        @symbol = color == 'w' ? "\u2658" : "\u265E"
    end
    
    def path_valid?(board, destination)
        move_collection = generate_possible_coors
        move_collection.any?(destination)
    end
    
    def generate_possible_coors
        possible_coors = move_pattern.map do |move| 
            move[0] += position[0]
            move[1] += position[1]
            move
        end
        possible_coors.delete_if {|move| !(move[0].between?(1,8) && move[1].between?(1,8))}
        possible_coors
    end
    private
    def move_pattern
        [[-1, -2], [-1, 2], [1, -2], [1, 2],
        [-2, -1], [-2, 1], [2, -1], [2, 1]]
    end
end



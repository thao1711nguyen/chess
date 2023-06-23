require_relative "rook.rb"

class Bishop < Rook
    def initialize(coordinator, color)
        @position = coordinator
        @color = color
        @name = 'B'
        @symbol = color == "w" ? "\u2657" : "\u265D"
    end
    
    private
    def move_pattern
        result = []
        [-1,1].repeated_permutation(2) { |permutation| result << permutation }
        result
    end
end
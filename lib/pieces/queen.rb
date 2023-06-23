require_relative "rook.rb"
class Queen < Rook
    
    def initialize(coordinator, color)
        @position = coordinator
        @color = color
        @name = 'Q'
        @symbol = color == "w" ? "\u2655" : "\u265B"
    end
    
    
    private
    def move_pattern
        result = []
        [-1,0,1].repeated_permutation(2) { |permutation| result << permutation }
        result.delete([0,0])
        result
    end
end
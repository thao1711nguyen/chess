
class Rook 
    attr_accessor :castle
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'R'
        @castle = true
        @symbol = color == 'w' ? "\u2656" : "\u265C"
    end
    
    
    def normal_pattern
        [[0,1], [1,0], [0,-1], [-1,0]]
    end
    def eat_pattern
        normal_pattern
    end
end
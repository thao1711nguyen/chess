
class Bishop 
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'B'
        @symbol = color == "w" ? "\u2657" : "\u265D"
    end
    
    def normal_pattern
        result = []
        [-1,1].repeated_permutation(2) { |permutation| result << permutation }
        result
    end
    def eat_pattern
        normal_pattern
    end 
    
end
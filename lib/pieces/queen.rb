class Queen
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'Q'
        @symbol = color == "w" ? "\u2655" : "\u265B"
    end
    
    
    def normal_pattern
        result = []
        [-1,0,1].repeated_permutation(2) { |permutation| result << permutation }
        result.delete([0,0])
        result
    end
    def eat_pattern 
        normal_pattern
    end 
    
end
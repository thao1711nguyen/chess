class King 
    attr_accessor :castle
    attr_reader :color, :name, :symbol
    def initialize(color)
        @color = color
        @name = 'K'
        @castle = true
        @symbol = color == 'w' ? "\u2654" : "\u265A"
    end
    
    def special_pattern
        [[2,0], [-2,0]]
    end
    def normal_pattern
        b = []
        [-1,0,1].repeated_permutation(2) { |per| b << per}
        b.delete([0,0])
        b 
    end
    def eat_pattern
        normal_pattern
    end

end
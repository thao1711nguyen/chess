class Knight
    attr_reader :name, :symbol, :color
    def initialize(color)
        @color = color
        @name = 'N'
        @symbol = color == 'w' ? "\u2658" : "\u265E"
    end
    
    
    def normal_pattern
        [[-1, -2], [-1, 2], [1, -2], [1, 2],
        [-2, -1], [-2, 1], [2, -1], [2, 1]]
    end

    def eat_pattern
        normal_pattern
    end
    
end



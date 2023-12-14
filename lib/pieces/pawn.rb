class Pawn 
    attr_reader :color, :name, :symbol
    attr_accessor :in_passing
    def initialize(color)
        @color = color
        @name = 'p'
        @in_passing = false
        @symbol = color == 'w' ? "\u2659" : "\u265F"
    end

    def normal_pattern
        if @color == 'w'
            [[0,1]]
        else 
            [[0,-1]]
        end
    end
    def special_pattern
        @color == 'w' ? [[0,2]] : [[0,-2]]
    end
    def eat_pattern 
        if @color == "w"
            [[-1,1], [1,1]]
        else 
            [[-1,-1], [1, -1]]
        end
    end
    def initial_position?(position)
        if @color == "w"
            initial_positions = (1..8).to_a.product([2])
        else 
            initial_positions = (1..8).to_a.product([7])
        end
        initial_positions.any?(position) 
    end
    def final_position?(position)
        if @color == "w"
            final_positions = (1..8).to_a.product([8])
        else 
            final_positions = (1..8).to_a.product([1])
        end
        final_positions.any?(position) 
    end
end
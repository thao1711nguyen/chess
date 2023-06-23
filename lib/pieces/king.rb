require_relative "knight.rb"
class King < Knight
    attr_accessor :castle
    def initialize(coordinator, color)
        @position = coordinator
        @color = color
        @name = 'K'
        @castle = true
        @symbol = color == 'w' ? "\u2654" : "\u265A"
    end
    
    
    private 
    def move_pattern
        b = []
        [-1,0,1].repeated_permutation(2) { |per| b << per}
        b.delete([0,0])
        b 
    end
end
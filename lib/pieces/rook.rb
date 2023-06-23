require_relative "serialize.rb"
require_relative "knight.rb"

class Rook < Knight
    include BasicSerialize
    attr_accessor :castle
    def initialize(coordinator, color)
        @position = coordinator
        @color = color
        @name = 'R'
        @castle = true
        @symbol = color == 'w' ? "\u2656" : "\u265C"
    end
    
    def get_direction(destination)
        direction = []
        position.each_with_index do |position_coor, idx|
            direction[idx] = destination[idx] - position_coor
        end
        if direction.any?(0) || direction[0].abs == direction[1].abs
            direction.each_with_index do |item, idx|
                case item
                when 0
                    next 
                when 1..7
                    direction[idx] = 1
                else 
                    direction[idx] = -1
                end
            end
        else  
            direction = []
        end
        direction
    end
    def path_valid?(board, destination)
        direction = get_direction(destination)
        return false unless move_pattern.any?(direction)
        step = position.dup
        loop do 
            step[0] += direction[0]
            step[1] += direction[1]
            return true if step == destination
            #meet obstacles & not reach the final destination
            return false unless board.get_status(step).nil?
        end
    end
    def coor_between(destination)
        direction = get_direction(destination)
        step = position.dup
        result = []
        loop do 
            step[0] += direction[0]
            step[1] += direction[1]
            return result if step == destination
            result << step.dup
        end
    end
    
    private
    def move_pattern
        [[0,1], [1,0], [0,-1], [-1,0]]
    end
end
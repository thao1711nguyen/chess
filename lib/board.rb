require_relative './square.rb'
require_relative './pieces/king.rb'
require_relative './pieces/queen.rb'
require_relative './pieces/knight.rb'
require_relative './pieces/rook.rb'
require_relative './pieces/bishop.rb'
require_relative './pieces/pawn.rb'
class Board 
    attr_accessor :squares, :in_passing
    def initialize
        @squares = create_board
        @in_passing = nil
    end
    def create_board 
        coor_collection = []
        (1..8).to_a.repeated_permutation(2) { |per| coor_collection << per}
        coor_collection.map do |coordinator|
            status = case coordinator
            when [1,1]
                Rook.new('w')
            when [2,1]
                Knight.new('w')
            when [3,1]
                Bishop.new('w')
            when [4,1]
                Queen.new('w')
            when [5,1]
                King.new('w')
            when [6,1]
                Bishop.new('w')
            when [7,1]
                Knight.new('w')
            when [8,1]
                Rook.new('w')
            # 
            
            when [1,8]
                Rook.new('b')
            when [2,8]
                Knight.new('b')
            when [3,8]
                Bishop.new('b')
            when [4,8]
                Queen.new('b')
            when [5,8]
                King.new('b')
            when [6,8]
                Bishop.new('b')
            when [7,8]
                Knight.new('b')
            when [8,8]
                Rook.new('b')
            end
            if coordinator[1] == 2 
                status = Pawn.new('w')
            elsif coordinator[1] == 7
                status = Pawn.new('b')
            end
            Square.new(coordinator, status)
        end
    end
    def display
        #Define box drawing characters
        side = '│'
        topbot = '─'
        tl = '┌'
        tr = '┐'
        bl = '└'
        br = '┘'
        ###############################
        coor_collection = []
        (1..8).to_a.repeated_permutation(2) { |per| coor_collection << per }
        coor_collection = coor_collection.group_by {|coor| coor[1]}
        #first frame
        draw = ["  ", tl]
        8.times { draw << (topbot*3+tr) }
        puts draw.join('')
        #middle frame 
        coor_collection.keys.sort.reverse.each do |row|
            draw = []
            draw << "#{row} " + side
            coor_collection[row].sort.each do |row_data|
                square_status = square(row_data).status
                if square_status.nil? 
                    draw << "   " + side 
                else 
                    draw <<  square_status.symbol.center(3) + side
                end
            end
            puts draw.join('')
            #bottom frame 
            draw = ["  ", bl]
            8.times { draw << (topbot*3+br) }
            puts draw.join('')
        end 
        draw = ["   "]
        ('a'..'h').to_a.each do |chr|
            draw << chr.center(3) + ' '
        end
        puts draw.join('')
    end
    def get_piece(name, coor, color)
        square = @squares.detect {|square| square.coordinator == coor && !square.status.nil? && square.status.color == color && square.status.name == name}
        square.status unless square.nil?
    end
    def status(coor)
        square = @squares.detect {|s| s.coordinator == coor}
        square.status unless square.nil?
    end
    def pieces(color)
        @squares.select {|s| !s.status.nil? && s.status.color == color}
    end
    def obstacle?(current, destination, pattern)
        step = current.dup
        loop do 
            step[0] += pattern[0]
            step[1] += pattern[1]
            return false if step == destination
            #meet obstacles & not reach the final destination
            return true unless status(step).nil?
        end
    end
    def square(coor)
        @squares.detect {|s| s.coordinator == coor}
    end
    def remove_in_passing #execute at the end of each turn
        pawns = @squares.select {|s| !s.status.nil? && s.status.name == 'p'}.map {|s| s.status}
        pawns.each do |pawn| 
            pawn.in_passing = false
        end
    end
    #not tested
    def get_king(color)
        @squares.detect {|square| !square.status.nil? && square.status.name == 'K' && square.status.color == color}
    end
end
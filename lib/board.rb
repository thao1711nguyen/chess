require_relative "pieces/square.rb"
class Board 
    attr_accessor :square_collection
    def initialize 
        @square_collection = []
    end
    def create_board 
        coor_collection = []
        (1..8).to_a.repeated_permutation(2) { |per| coor_collection << per}
        coor_collection.each do |coordinator|
            @square_collection << Square.new(coordinator)
        end
    end
    def get_square(coordinator)
        @square_collection.detect { |square| square.coordinator == coordinator }   
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
                square_status = get_square(row_data).status
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
    def change_status(coor, status)
        square = get_square(coor)
        square.status = status   
    end
    def get_status_color(coor)
        square = get_square(coor)
        square.status.nil? ? nil : square.status.color
    end
    def get_status(coor)
        get_square(coor).status
    end
end
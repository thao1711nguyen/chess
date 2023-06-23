require "require_all"
require_all "./lib/pieces"

class Player
    include BasicSerialize
    attr_reader :color
    attr_accessor :pieces
    def initialize(color)
        @color = color
        @pieces = [] #collection  of piece object  
    end
    def create_new_pieces
        if color == 'w'
            rook_1 = Rook.new([1,1], 'w')
            rook_2 = Rook.new([8,1], 'w')
            knight_1 = Knight.new([2,1], 'w')
            knight_2 = Knight.new([7,1], 'w')
            bishop_1 = Bishop.new([3,1], 'w')
            bishop_2 = Bishop.new([6,1], 'w')
            queen = Queen.new([4,1], 'w')
            king = King.new([5,1], 'w')
            pawn_collection = (1..8).to_a.product([2]).map { |coor| Pawn.new(coor, 'w') }
        else 
            rook_1 = Rook.new([1,8], 'b')
            rook_2 = Rook.new([8,8], 'b')
            knight_1 = Knight.new([2,8], 'b')
            knight_2 = Knight.new([7,8], 'b')
            bishop_1 = Bishop.new([3,8], 'b')
            bishop_2 = Bishop.new([6,8], 'b')
            queen = Queen.new([4,8], 'b')
            king = King.new([5,8], 'b')
            pawn_collection = (1..8).to_a.product([7]).map { |coor| Pawn.new(coor, 'b') }
        end
        [rook_1, rook_2, knight_1, knight_2, bishop_1, bishop_2, queen, king] + pawn_collection
    end
    def get_piece(name, coordinator=nil)
        if coordinator == nil 
            @pieces.select { |piece| piece.name == name }
        else  
            @pieces.detect { |piece| piece.name == name && piece.position == coordinator }
        end
    end
    def promote(piece_name, coordinator)
        case piece_name 
        when 'Q'
            piece = Queen.new(coordinator, color)
        when 'B'
            piece = Bishop.new(coordinator, color)
        when 'R' 
            piece = Rook.new(coordinator, color)
        when 'N' 
            piece = Knight.new(coordinator, color) 
        end 
        pieces << piece
        piece
    end
    def check_castle?
        king = get_piece('K')[0]
        rooks = get_piece('R')
        king.castle ? rooks.map(&:castle).any?(true) : false
    end
    def serialize 
        obj = {}
        obj[:@pieces] = @pieces.map {|piece| piece.serialize }
        @@serializer.dump obj
    end
    
    def unserialize(hash_data)
        hash = @@serializer.load(hash_data)
        hash[:@pieces].each do |piece_data|
            @pieces << piece_unserialize(piece_data)
        end
    end
    
end
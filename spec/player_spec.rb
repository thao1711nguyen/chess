require "./lib/player.rb"
#require "require_all"
#require_all "./lib/pieces"

describe Player do 
    subject(:player) { described_class.new('w') }
    describe "#create_new_pieces" do 
        it "return 16 pieces" do 
            expect(player.create_new_pieces.length).to eq 16
        end
        it "have 2 rooks" do 
            rooks = player.create_new_pieces.select {|piece| piece.instance_of? Rook }
            expect(rooks.length).to eq 2
        end
        it "have 2 bishops" do 
            bishops = player.create_new_pieces.select {|piece| piece.instance_of? Bishop }
            expect(bishops.length).to eq 2
        end
        it "have 2 knights" do 
            knights = player.create_new_pieces.select {|piece| piece.instance_of? Knight }
            expect(knights.length).to eq 2
        end
        it "have 1 queen" do 
            queen = player.create_new_pieces.select {|piece| piece.instance_of? Queen }
            expect(queen.length).to eq 1
        end
        it "have 1 king" do 
            king = player.create_new_pieces.select {|piece| piece.instance_of? King }
            expect(king.length).to eq 1
        end
        it "have 8 pawns" do 
            pawns = player.create_new_pieces.select {|piece| piece.instance_of? Pawn }
            expect(pawns.length).to eq 8
        end
    end
    describe "#get_piece" do 
        context "when name and coordinator are provided and the piece exists" do 
            it "return the piece" do 
                pieces = player.create_new_pieces
                player.instance_variable_set(:@pieces, pieces)
                expect(player.get_piece('R', [1,1])).to be_an_instance_of Rook 
            end
        end
        context "when name and coordinator are provided but piece does not exist" do 
            it "return nil" do 
                pieces = player.create_new_pieces
                player.instance_variable_set(:@pieces, pieces)
               
                expect(player.get_piece('R', [1,2])).to be_nil
            end
        end
        context "when only name is provided and it does not exist" do 
            it "return nil" do 
                pieces = player.create_new_pieces
                player.instance_variable_set(:@pieces, pieces)
                player.pieces.delete_if {|piece| piece.name == 'R'}
                expect(player.get_piece('R', [1,2])).to be_nil
            end
        end
        context "when only name is provided" do 
            it "return an array of piece" do 
                pieces = player.create_new_pieces
                player.instance_variable_set(:@pieces, pieces)
                expect(player.get_piece('R').length).to eq 2
            end
        end
    end
    describe "#promote" do 
        it "return a piece" do
            pieces = player.create_new_pieces
            player.instance_variable_set(:@pieces, pieces) 
            expect(player.promote('Q', [1,1])).to be_an_instance_of Queen
        end
        it "increase pieces_collection by 1" do
            pieces = player.create_new_pieces
            player.instance_variable_set(:@pieces, pieces)
            expect {player.promote('Q', [1,1]) }.to change { player.pieces.length }.by(1)
        end
    end
end
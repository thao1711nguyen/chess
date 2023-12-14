require_relative './../refactor/board.rb'
describe Board do 
    subject(:board) { described_class.new }
    describe "#create_board" do 
        
        it "create 64 square-objects" do 
            expect(Square).to receive(:new).exactly(64).times
            Board.new
        end
        it "return an array, whose length is 64" do 
            expect(board.squares.length).to eq 64
        end
        it "contain 4 rooks" do 
            expect(board.squares.filter {|s| s.status.instance_of? Rook}.length).to eq 4
        end
        it "contain 4 knights" do 
            expect(board.squares.filter {|s| s.status.instance_of? Knight}.length).to eq 4
        end
        it "contain 4 bishops" do 
            expect(board.squares.filter {|s| s.status.instance_of? Bishop}.length).to eq 4
        end
        it "contain 2 queen" do 
            expect(board.squares.filter {|s| s.status.instance_of? Queen}.length).to eq 2
        end 
        it "contain 2 king" do 
            expect(board.squares.filter {|s| s.status.instance_of? King}.length).to eq 2
        end 
        it "contain 16 pawns" do 
            expect(board.squares.filter {|s| s.status.instance_of? Pawn}.length).to eq 16

        end
    end
    describe "#get_piece" do 
        let(:square) { double('square', coordinator: [2,1])}
        let(:pawn) { double('pawn', color: 'w', name: 'p')}
        before do 
            board.squares = [square]
        end
        context "return nil when" do 
            it "square is nil" do 
                allow(square).to receive(:status).and_return nil
                expect(board.get_piece('p', [2,1], 'w')).to be_nil
            end
            it "color not match" do 
                allow(square).to receive(:status).and_return(pawn)
                expect(board.get_piece('p', [2,1], 'b')).to be_nil
            end
            it "name not match" do 
                allow(square).to receive(:status).and_return(pawn)
                expect(board.get_piece('R', [2,1], 'b')).to be_nil
            end
        end 
        it "return piece" do 
            allow(square).to receive(:status).and_return(pawn)
            expect(board.get_piece('p', [2,1], 'w')).to eq pawn
        end

    end
    describe "#status" do 
        let(:rook) { double('rook')}
        let (:square1) { double('square1', coordinator: [2,1], status: nil)}
        let (:square2) { double('square2', coordinator: [2,2], status: rook)}
        before do 
            board.squares = [square1, square2]
        end 
        context "return nil when" do 
            it "no coor match" do 
                coor = [3,4]
                expect(board.status(coor)).to be_nil
            end
            it "status is nil" do 
                coor = [2,1]
                expect(board.status(coor)).to be_nil
            end
        end
        it "return a piece" do 
            coor = [2,2]
            expect(board.status(coor)).to eq rook
        end
    end
    describe "#pieces" do 
        let(:queen) { double('queen', color: 'w')}
        let(:knight) { double('knight', color: 'w')}
        let(:king) { double('king', color: 'b')}
        let(:square1) { double('square1', status: nil)}
        let(:square2) { double('square2', status: queen)}
        let(:square3) { double('square3', status: nil)}
        let(:square4) { double('square4', status: knight)}
        let(:square5) { double('square5', status: king)}
        before do
            board.squares = [square1, square2, square3, square4, square5]
        end
        it "return white's pieces" do 
            expect(board.pieces('w')).to eq [square2, square4]
        end
        it "return black's pieces" do 
            expect(board.pieces('b')).to eq [square5]
        end
    end
    describe "#obstacle?" do 
        it "return true" do 
            current = [1,2]
            destination = [1,7]
            pattern = [0,1]
            allow(board).to receive(:status).and_return(nil)
            expect(board.obstacle?(current, destination, pattern)).to eq true
        end
        it "return false" do 
            current = [1,2]
            destination = [1,7]
            pattern = [0,1]
            allow(board).to receive(:status).and_return(nil, nil, nil, true)
            expect(board.obstacle?(current, destination, pattern)).to eq false
        end
    end
    # describe "#remove_in_passing" do
    #     it "" do 
    #         pawn1 =  double('pawn1', name:'p', in_passing: false) 
    #         pawn2 = double('pawn2', name: 'p', in_passing: false)
    #         pawn3 = double('pawn3', name: 'p', in_passing: true)
    #         pawn4 = double('pawn4', name: 'p', in_passing: false)
    #         square1 = double('square1', status: pawn1)
    #         square2 = double('square2', status: pawn2)
    #         square3 = double('square3', status: pawn3)
    #         square4 = double('square4', status: nil)
    #         square5 = double('square5', status: pawn4)
    #         square6 = double('square6', status: nil)
    #         square7 = double('square7', status: nil)
    #         squares = [square1, square2, square3, square4, square5, square6, square7]
    #         pawns = [pawn1, pawn2, pawn3, pawn4]
    #         pawns.each do |pawn|
    #             allow(pawn).to receive(:in_passing=)
    #         end
    #         board.squares = squares
    #         board.remove_in_passing
    #         # p board.squares.select {|s| !s.status.nil? && s.status.name == 'p' && !s.status.in_passing}
    #         expect(board.squares.select {|s| !s.status.nil? && s.status.name == 'p' && !s.status.in_passing}.length).to eq 4
    #     end
    # end
end
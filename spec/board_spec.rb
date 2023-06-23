require "./lib/board.rb"
require "./lib/pieces/square.rb"

describe Board do 
    subject(:board) { described_class.new }
    describe "#create_board" do 
        it "return an array, whose length is 64" do 
            board.create_board
            expect(board.square_collection.length).to eq 64
        end
        it "create 64 square-objects" do 
            expect(Square).to receive(:new).exactly(64).times
            board.create_board
            
        end
    end
    describe "#get_square" do 
        it "return a square object" do 
            board.create_board
            expect(board.get_square([1,1])).to be_an_instance_of Square
        end
        it "return the right square object" do 
            board.create_board
           
            expect(board.get_square([1,1]).coordinator).to eq [1,1]
        end
    end
    describe "#change_status" do 
        #let(:square) { instance_double(Square, status: nil) }
        square = Square.new([1,1])
        let(:pawn) { double('Pawn') }
        it "send message to change status" do 
            allow(board).to receive(:get_square).and_return(square)
            
            expect { board.change_status([1,1], pawn) }.to change { square.status }.to(pawn)
        end
    end
    describe "#get_status_color" do 
        let(:square) { double('Square') }
        let(:knight) { double('Knight', color: 'w') }
        before do 
            allow(board).to receive(:get_square).and_return(square)
        end
        it "return nil when no piece occupies the square" do 
            allow(square).to receive(:status).and_return(nil)
            expect(board.get_status_color([1,1])).to be_nil
        end
        it "return piece's color when square is occupied" do 
            allow(square).to receive(:status).and_return(knight)
            expect(board.get_status_color([1,1])).to eq 'w'
        end
    end
    describe "#get_status" do 
        let(:square) { double('Square') }
        before do 
            allow(board).to receive(:get_square).and_return(square)
        end
        it "return nil if status is nil" do 
            allow(square).to receive(:status).and_return(nil)
            expect(board.get_status([1,1])).to eq nil
        end
        it "return a piece if status not nil" do 
            allow(square).to receive(:status).and_return('rook')
            expect(board.get_status([1,1])).to eq 'rook'
        end
    end
end

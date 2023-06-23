require "./lib/pieces/rook.rb"
require "./lib/pieces/square.rb"
require "./lib/pieces/pawn.rb"
require "./lib/board.rb"


describe Rook do 
    subject(:rook) { described_class.new([5,5], 'b')}
    describe "#get_direction" do 
        context "when destination coordinator is specified" do 
            it 'when destination is [5,8] rurn [0,1]' do 
                expect(rook.get_direction([5,8])).to eq [0,1]
            end
            it 'when destination is [8,5] rurn [1,0]' do 
                expect(rook.get_direction([8,5])).to eq [1,0]
            end
            it 'when destination is [6,1] rurn [0,-1]' do 
                expect(rook.get_direction([5,1])).to eq [0,-1]
            end
            it 'when destination is [2,5] rurn [-1,0]' do 
                expect(rook.get_direction([2,5])).to eq [-1,0]
            end
            
        end
    end
    describe "#path_valid?" do 
        
        let(:board) { double('Board') }
        context "when make the right move" do
            before do 
                allow(rook).to receive(:get_direction).and_return([0,-1])
                allow(board).to receive(:get_status).and_return(nil)
            end
            it "return true" do 
                expect(rook.path_valid?(board, [5,1])).to eq true
            end
        end
        context "when it is not the move pattern" do 
            before do 
                allow(rook).to receive(:get_direction).and_return([1,-1])
            end
            it "return false" do 
                expect(rook.path_valid?(board, [2,6])).to eq false
            end
        end
        context "when there is obstacle" do 
            before do 
                allow(rook).to receive(:get_direction).and_return([0,-1])
                allow(board).to receive(:get_status).and_return(nil, nil, 'pawn')
            end
            it "return false" do 
                expect(rook.path_valid?(board, [5,1])).to eq false
            end
        end
        context "when there are three squares between and they do not contain any obstacle" do 
            before do 
                allow(rook).to receive(:get_direction).and_return([0,-1])
                allow(board).to receive(:get_status).and_return(nil, nil, nil)                
            end
            it "return true" do 
                expect(rook.path_valid?(board, [5,1])).to eq true
            end
        end
        context "when there are three squares between and one has obstacle" do 
            
            before do 
                allow(rook).to receive(:get_direction).and_return([0,-1])
                allow(board).to receive(:get_status).and_return(nil,nil,'pawn')
            end
            it "return false" do 
                expect(rook.path_valid?(board, [5,1])).to eq false
            end
        end
    end
    describe "#coor_between" do 
        context "when destination is specified" do 
            it "return [[4,5], [3,5], [2,5]]" do 
                expect(rook.coor_between([1,5])).to eq [[4,5], [3,5], [2,5]]
            end
        end
    end
end
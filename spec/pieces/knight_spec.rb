require "./lib/pieces/knight.rb"
require "./lib/pieces/square.rb"
require "./lib/board.rb"
describe Knight do 
    subject(:knight) { described_class.new([1,1], 'w') }
   
    describe "#generate_possible_coors" do
         it "return an array of moves" do
            expect(knight.generate_possible_coors).to eq [ [2, 3],[3, 2]]
         end
    end

    describe "#path_valid?" do 
        let(:board) { double("Board") }
        context "when destination is valid" do 
            it "return true" do 
                expect(knight.path_valid?(board, [3,2])).to eq true
            end
        end
        context "when destination is invalid" do 
            it "return false" do 
                expect(knight.path_valid?(board, [3,3])).to eq false
            end
        end
    end
end
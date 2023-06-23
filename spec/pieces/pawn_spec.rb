require "./lib/pieces/pawn.rb"
require "./lib/pieces/square.rb"
describe Pawn do 
    subject(:pawn) { described_class.new([1,2], 'w') }
    describe "#initial_position?" do 
        context "when it is true" do 
            it "return true" do 
                expect(pawn.initial_position?).to eq true
            end
        end
        context "when it is false" do 
            it "return false" do 
                pawn.instance_variable_set(:@position, [1,1])
                expect(pawn.initial_position?).to eq false
            end
        end
    end
    describe "#eat?" do 
        
        context "when move is valid" do 
            it "can eat" do 
                expect(pawn.eat?([2,3])).to eq true
            end
        end
        context "when move is not valid" do 
            
            it "can not eat" do 
                expect(pawn.eat?([2,1])).to eq false
            end
        end
    end
    describe "#get_direction" do 
        context "when move forward" do 
            it "y-coordinate should be > 0" do 
                pawn.position = [1,2]
                expect(pawn.get_direction([1,3])).to eq [0, 1]
            end
        end
        context "when move backward" do 
            it "y-coordinate should be < 0" do 
                pawn.position = [1,7]
                expect(pawn.get_direction([1,6])).to eq [0, -1]
            end
        end
    end
    describe "#promote?" do 
        context "when pawn is not at the final position" do 
            before do 
                allow(pawn).to receive(:final_position?).and_return(false)
            end
            it "return nil" do 
                expect(pawn.promote?).to be_nil
            end
        end
        context "when enter a valid name the first time" do 

            before do 
                allow(pawn).to receive(:final_position?).and_return(true)
                allow(pawn).to receive(:puts).twice 
                allow(pawn).to receive_message_chain(:gets, :chomp, :strip).and_return('Q')
            end
            it "return name" do 
                expect(pawn.promote?).to eq "Q"
            end
            it "do not print error message" do 
                error_message = "Please enter a valid piece!"
                expect(pawn).not_to receive(:puts).with(error_message)
                pawn.promote?
            end
        end
        context "when enter an invalid name and then a valid name" do 
            before do 
                allow(pawn).to receive(:final_position?).and_return(true)
                allow(pawn).to receive(:puts).with("Which piece would you like your pawn to become? ").twice
                allow(pawn).to receive(:puts).with("Queen(Q), Rook(R), Bishop(B) or Knight(N)").twice
                allow(pawn).to receive(:puts).with("Please enter a valid piece!").once
                allow(pawn).to receive_message_chain(:gets, :chomp, :strip).and_return('q','Q')
            end
            it "return name" do 
                expect(pawn.promote?).to eq "Q"
            end
            it "print error message once" do 
                error_message = "Please enter a valid piece!"
                expect(pawn).to receive(:puts).with(error_message).once
                pawn.promote?
            end
        end
    end
end
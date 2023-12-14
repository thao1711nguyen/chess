require_relative "./../refactor/game.rb"
describe Game do
    subject(:game) { described_class.new}
    describe "#get_move" do  
        
        let(:player) { double('Player') }
        context "move a pawn" do 
            
            before do 
                allow(game).to receive(:ask).and_return(['a','2','-','a','3'])
            end
            it "return a pawn move" do 
                expect(game.get_move(player)).to eq ['a','2','-','a','3']
            end
            
        end
        context "move a rook" do 
            before do 
                allow(game).to receive(:ask).and_return(['R','a','1','-','R','a','6'])
            end
            it "return a rook's mvoe" do 
                expect(game.get_move(player)).to eq ['R','a','1','-','R','a','6']
            end
            
            
        end
        context "return nil when move's format wrong" do 
            it "wrong piece's name" do 
                allow(game).to receive(:ask).and_return(['H', 'h', '3', '-', 'H', 'a', '6'])
                expect(game.get_move(player)).to be_nil
            end
            it "wrong square's notation" do 
                allow(game).to receive(:ask).and_return(['Q', 'H', '3', '-', 'h', 'a', '6'])
                expect(game.get_move(player)).to be_nil
            end
            it "missing piece's name" do 
                allow(game).to receive(:ask).and_return(['Q', 'h', '3', '-', 'a', '6'])
                expect(game.get_move(player)).to be_nil
            end
        end
        
        
    end
    describe "#transform" do 
        it "pawn's move" do 
            move = "c3-c5".split('')
            expect(game.transform(move)).to eq({piece: 'p', current: [3,3], destination: [3,5]})
        end
        it "queen's move" do 
            move = "Qe7-Qb4".split('')
            expect(game.transform(move)).to eq({piece: 'Q', current: [5,7], destination: [2,4]})
        end
    end
    describe "#convert_pattern" do 
        it "queen pattern" do
            queen = double('queen', name: 'Q')
            square1 = double('square1', coordinator: [3,2], status: queen)
            square2 = double('square2', coordinator: [1,4])
            move = {current: square1, destination: square2}
            expect(game.convert_pattern(move)).to eq [-1,1]
        end
        it "rook pattern" do 
            rook = double('rook', name: 'R')
            square1 = double('square1', coordinator: [1,1], status: rook)
            square2 = double('square2', coordinator: [1,8])
            move = {current: square1, destination: square2}
            expect(game.convert_pattern(move)).to eq [0,1]
        end
        it "pawn pattern" do 
            king = double('king', name: 'K')
            square1 = double('square1', coordinator: [2,7], status: king)
            square2 = double('square2', coordinator: [2,5])
            move = {current: square1, destination: square2}
            expect(game.convert_pattern(move)).to eq [0,-2]
        end
    end 
    describe "#get_path" do 
        let(:board) { double('board') }
        let(:player) { 'w' }
        let(:opponent) { 'b'}
        let(:move) {}
        before do 
            allow(game).to receive(:convert_pattern).and_return([1,1])
        end
        it "return pawn first" do 

            pawn = double('pawn first')
            
            allow(game).to receive(:special_pattern).and_return('pawn first')
            expect(game.get_path(player, opponent, pawn, move)).to eq 'pawn first'
        end
        it "return pawn last" do 
            pawn = double('pawn last')
            allow(game).to receive(:special_pattern).and_return('pawn last')
            expect(game.get_path(player, opponent, pawn, move)).to eq 'pawn last'
            
        end
        it "return in-passing" do 
            pawn = double('in-passing')
            allow(game).to receive(:special_pattern).and_return('in-passing')
            expect(game.get_path(player, opponent, pawn, move)).to eq 'in-passing'
            
        end
        it "return a rook" do 
            rook = double('rook')
            allow(game).to receive(:special_pattern).and_return(rook)
            expect(game.get_path(player, opponent, rook, move)).to eq rook 
            
        end
        context "return normal when" do 
            before do 
                allow(game).to receive(:special_pattern).and_return(nil)
            end
            it "pawn forward move" do 
                pawn = double('pawn forward', name: 'p', normal_pattern: [[1,1]])
                expect(game.get_path(player, opponent, pawn, move)).to eq 'normal'
            end
            it "pawn eat move" do 
                piece = double('piece', color: 'b')
                move = { destination: piece }
                board = double('board')
                game.board = board
                pawn = double('pawn eat', name: 'p', normal_pattern: [], eat_pattern: [[1,1]])
                allow(board).to receive(:status).and_return(piece)
                expect(game.get_path(player, opponent, pawn, move)).to eq 'normal'
                
            end
            it "other pieces normal move" do 
                allow(game).to receive(:convert_pattern).and_return([1,1])
                rook = double('rook', name: 'R', normal_pattern: [[1,1]])
                expect(game.get_path(player, opponent, rook, move)).to eq 'normal'
            end
        end
    end
    describe "#in_passing?" do 
        let(:pawn) { double('pawn', color: 'w') }
        let(:square1) { double('square1', coordinator: [1,2])}
        let(:square2) { double('square2', coordinator: [2,3])}
        let(:move) { {current: square1, destination: square2 }}
        let(:board) { double('board')}
        before do
            game.board = board 
        end
        it "return true" do 
            pattern = [1,1]
            in_passing = double('in-passing', position: [2,2], in_passing: true)
            in_passing_square = double('in-passing-square', status: in_passing)
            allow(pawn).to receive(:eat_pattern).and_return([[1,1]])
            allow(board).to receive(:square).and_return(in_passing_square)
            expect(game.in_passing?(pattern, pawn, move)).to eq true
        end
        context "return false when" do 
            it "does not match eat pattern" do 
                pattern = [1,0] 
                in_passing = double('in-passing', position: [2,2], in_passing: true)
                in_passing_square = double('in-passing-square', status: in_passing)

                allow(pawn).to receive(:eat_pattern).and_return([[1,1]])
                allow(board).to receive(:square).and_return(in_passing_square)
                expect(game.in_passing?(pattern, pawn, move)).to eq false
                
            end
            
            it "eaten pawn is not the in-passing pawn" do 
                pattern = [1,1] 
                in_passing = double('in-passing', position: [2,6], in_passing: false)
                in_passing_square = double('in-passing-square', status: in_passing)

                allow(pawn).to receive(:eat_pattern).and_return([[1,1]])
                allow(board).to receive(:square).and_return(in_passing_square)
                expect(game.in_passing?(pattern, pawn, move)).to eq false
            end
        end
    end
    describe "#castle?" do 
        let(:player) { 'w' }
        let(:opponent) { 'b' }
        let(:king) { double('king', position: [1,2])}
        let(:rook) { double('rook', position: [2,3])}
        let(:board) { double('board') }
        let(:square1) { double('square1', coordinator: [1,1])}
        let(:square2) { double('square2', coordinator: [3,1])}
        let(:move) { {current: square1, destination: square2}}
        before do 
            game.board = board
        end
        
        context "return nil when" do 
            it "no rook is found" do 
                allow(board).to receive(:get_piece).and_return(nil)
                allow(king).to receive(:castle).and_return(true)
                expect(game.castle?(player, opponent, move, king)).to be_nil

            end
            it "king moved already" do 
                allow(board).to receive(:get_piece).and_return(rook)
                allow(rook).to receive(:castle).and_return(true)
                allow(king).to receive(:castle).and_return(false)
                expect(game.castle?(player, opponent, move, king)).to be_nil

            end
            it "rook moved already" do 
                allow(board).to receive(:get_piece).and_return(rook)
                allow(rook).to receive(:castle).and_return(false)
                allow(king).to receive(:castle).and_return(true)
                expect(game.castle?(player, opponent, move, king)).to be_nil

            end
            
            it "king is being checked" do 
                square3 = double('square3')
                square4 = double('square4')
                allow(board).to receive(:pieces).and_return([square3, square4])
                allow(game).to receive(:can_eat?).and_return(false, true)
                allow(board).to receive(:get_piece).and_return(rook)
                allow(rook).to receive(:castle).and_return(true)
                allow(king).to receive(:castle).and_return(true)
                expect(game.castle?(player, opponent, move, king)).to be_nil
                
            end
            it "there is obstacle between rook and king" do 
                square5 = double('square5')
                square6 = double('square6')
                allow(board).to receive(:pieces).and_return([square5, square6])
                allow(game).to receive(:can_eat?).and_return(false, false)
                allow(board).to receive(:get_piece).and_return(rook)
                allow(rook).to receive(:castle).and_return(true)
                allow(king).to receive(:castle).and_return(true)
                allow(game).to receive(:convert_pattern).and_return([])
                allow(board).to receive(:square).and_return([])
                allow(board).to receive(:obstacle?).and_return(true)
                expect(game.castle?(player, opponent, move, king)).to be_nil
                
            end
        end
        context "return rook" do 
            it "" do 
                square7 = double('square7')
                square8 = double('square8')
                allow(board).to receive(:pieces).and_return([square7, square8])
                allow(game).to receive(:can_eat?).and_return(false, false)
                allow(board).to receive(:get_piece).and_return(rook)
                allow(rook).to receive(:castle).and_return(true)
                allow(king).to receive(:castle).and_return(true)
                allow(game).to receive(:convert_pattern).and_return([])
                allow(board).to receive(:square).and_return([])
                allow(board).to receive(:obstacle?).and_return(false)
                expect(game.castle?(player, opponent, move, king)).to eq rook

            end
        end
    end
    describe "#can_eat?" do 
        let(:piece) {double('piece', eat_pattern: [[2,2]])}
        let(:attack) { double('attack', coordinator: [3,4], status: piece)}
        let(:defense) { double('defense', coordinator: [3,6])}
        let(:board) { double('board') }
        before do 
            game.board = board 
        end
        context "return false when" do 
            it "eat pattern not match" do 
                allow(game).to receive(:convert_pattern).and_return([1,1])
                expect(game.can_eat?(attack, defense)).to eq false
            end 
            it "there is obstacle" do 
                allow(game).to receive(:convert_pattern).and_return([2,2])
                allow(board).to receive(:ostacle?).and_return(true)
                expect(game.can_eat?(attack, defense)).to eq false
                
            end
        end
        it "return true" do 
            allow(game).to receive(:convert_pattern).and_return([2,2])
            allow(board).to receive(:ostacle?).and_return(false)
            expect(game.can_eat?(attack, defense)).to eq true

        end
    end
    
end
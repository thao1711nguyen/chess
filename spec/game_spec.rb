require "./lib/game.rb"
describe Game do 
    subject(:game) { described_class.new }
    
    describe "#transform_coordinator" do 
        context "when coordinator is specified" do 
            it "return [1,2]" do 
                expect(game.transform_coordinator(['a', '2'])).to eq [1,2]
            end
            it "return [4,3]" do 
                expect(game.transform_coordinator(['d', '3'])).to eq [4,3]
            end

        end
    end
    describe "#introduce" do 
        welcome = 'Welcome to the game!'
        guide = "Press 'n' if you want to play new game and 'c' if you want to continue previous game"
        error = "Please enter a valid answer!"
        context "when there is no saved game" do
            before do 
                allow(File).to receive(:zero?).and_return(true)
                allow(game).to receive(:puts).with(welcome).once
               
            end 
            it "return nil" do 
                expect(game.introduce).to be_nil
            end
            it "print the welcome statement" do 
                expect(game).to receive(:puts).with(welcome).once
                game.introduce
            end
            it "do not print guide statement" do 
                expect(game).not_to receive(:puts).with(guide)
                game.introduce
            end
        end
        context "when there is saved game and user enters valid answer" do 
            before do 
                allow(game).to receive(:puts).with(welcome)
                allow(File).to receive(:zero?).and_return(false)
                allow(game).to receive(:puts).with(guide)
                allow(game).to receive_message_chain(:gets, :chomp, :strip).and_return('c')
            end
            it "ask for new or old game once" do 
                expect(game).to receive(:puts).with(guide).once
                game.introduce
            end
            it "return answer" do 
                expect(game.introduce).to eq "c"
            end
            it "do not output error message" do 
                expect(game).not_to receive(:puts).with(error)
                game.introduce
            end
        end
        context "when there is saved game and user enter an invalid answer, then a valid one" do 
            before do 
                allow(game).to receive(:puts).with(welcome)
                allow(File).to receive(:zero?).and_return(false)
                allow(game).to receive(:puts).with(guide)
                allow(game).to receive_message_chain(:gets, :chomp, :strip).and_return('sfs','c')
                allow(game).to receive(:puts).with(error)
            end
            it "ask for new or old game twice" do 
                expect(game).to receive(:puts).with(guide).twice
                game.introduce
            end
            it "output error message" do 
                expect(game).to receive(:puts).with(error).once
                game.introduce
            end
            it "return answer" do 
                expect(game.introduce).to eq 'c'
            end
        end
    end
    describe "#get_move" do  #fix this test 
        
        let(:player) { double('Player') }
        context "when move a pawn and no obstacle" do 
            let(:pawn) { double('Pawn', name: 'p', position: [1,2]) }
            
            before do 
                allow(game).to receive(:ask).and_return(['a','2','-','a','3'])
                allow(game).to receive(:transform_coordinator).and_return([1,2], [1,3])
                allow(player).to receive(:get_piece).and_return(pawn)
                allow(game).to receive(:pass_basic_condition).and_return(true)
                
            end
            it "return a pawn" do 
                expect(game.get_move(player)[0]).to eq pawn
            end
            it "return position" do 
                expect(game.get_move(player)[1]).to eq [1,2]
            end
            it "return destination" do 
                expect(game.get_move(player)[2]).to eq [1,3]
            end
        end
        context "when move other pieces such as a rook and there is no obstacle" do 
            let(:rook) { instance_double(Rook) }
            before do 
                allow(game).to receive(:ask).and_return(['R','a','1','-','R','a','6'])
                allow(player).to receive(:get_piece).with('R', [1,1]).and_return(rook)
                allow(game).to receive(:pass_basic_condition).and_return(true)
            end
            it "return a rook" do 
                expect(game.get_move(player)[0]).to eq rook
            end
            
            it "return position square" do 
                expect(game.get_move(player)[1]).to eq [1,1]
                
            end
            it "return destination square" do 
                expect(game.get_move(player)[2]).to eq [1,6]
            end
        end
        context "return nil when move's format wrong (example of correct format: Qh3-Qa6)" do 
            xit "wrong piece's name" do 
                allow(game).to receive(:ask).and_return(['H', 'h', '3', '-', 'H', 'a', '6'])
                expect(game.get_move(player)).to be_nil
            end
            xit "wrong square's notation" do 
                allow(game).to receive(:ask).and_return(['Q', 'H', '3', '-', 'h', 'a', '6'])
                expect(game.get_move(player)).to be_nil
            end
            xit "missing piece's name" do 
                allow(game).to receive(:ask).and_return(['Q', 'h', '3', '-', 'a', '6'])
                expect(game.get_move(player)).to be_nil
            end
        end
        context "when move dead piece" do 
            xit "return nil" do 
                allow(game).to receive(:ask).and_return(['Q', 'a', '1', '-', 'Q', 'a', '4'])
                allow(player).to receive(:get_piece).and_return(nil)
                expect(game.get_move(player)).to be_nil
            end
        end
        context "when piece is correct but destination contains player's piece" do 
            
            let(:board) { instance_double(Board) }
            let(:pawn) { instance_double(Pawn, color: 'w') }
            before do 
                allow(game).to receive(:ask).and_return(['Q', 'a', '1', '-', 'Q', 'a', '4'])
                allow(player).to receive(:get_piece).and_return(instance_double(Queen))
                allow(board).to receive(:get_square).with([1,4]).and_return(instance_double(Square, status: pawn))
                allow(player).to receive(:color).and_return('w')
                game.board = board
            end
            xit "return nil" do 
                expect(game.get_move(player)).to be_nil
            end
        end
    end
    describe "#is_eaten_by" do 
        let(:opponent) { double('Player') }
        
        let(:opponent_queen) { double('Queen', name: 'Q') }
        let(:opponent_bishop) { double('Bishop', name: 'B') }
        let(:opponent_pawn) { double('Pawn', name: 'p')}
        context "when king is not checked" do 
            before do 
                allow(opponent).to receive(:pieces).and_return([opponent_queen, opponent_bishop, opponent_pawn])
                allow(opponent_queen).to receive(:path_valid?).and_return(false)
                allow(opponent_bishop).to receive(:path_valid?).and_return(false)
                allow(opponent_pawn).to receive(:eat?).and_return(false)
            end
            it "return an empty array" do
                expect(game.is_eaten_by(opponent, [1,1])).to be_empty 
            end
        end
        context "when king is checked by 2 pieces" do 
            before do 
                allow(opponent).to receive(:pieces).and_return([opponent_queen, opponent_bishop, opponent_pawn])
                allow(opponent_queen).to receive(:path_valid?).and_return(true)
                allow(opponent_bishop).to receive(:path_valid?).and_return(false)
                allow(opponent_pawn).to receive(:eat?).and_return(true)
            end
            it "return an array of 2" do 
                expect(game.is_eaten_by(opponent, [1,1]).length).to eq 2
            end
        end
        context "when king is checked by 1 piece" do 
            before do 
                allow(opponent).to receive(:pieces).and_return([opponent_queen, opponent_bishop, opponent_pawn])
                allow(opponent_queen).to receive(:path_valid?).and_return(false)
                allow(opponent_bishop).to receive(:path_valid?).and_return(true)
                allow(opponent_pawn).to receive(:eat?).and_return(false)
            end
            it "return an array of 1" do 
                expect(game.is_eaten_by(opponent, [1,1]).length).to eq 1
            end 
        end            
    end
    describe "#set_up" do 
        let(:board) { instance_double(Board) }
        let(:white) { instance_double(Player) }
        let(:black) { instance_double(Player) }
        let(:pawn) { double('Pawn') }
        before do 
            allow(white).to receive(:pieces).and_return([pawn, pawn, pawn])
            allow(black).to receive(:pieces).and_return([pawn, pawn, pawn])
            allow(pawn).to receive(:position).and_return([1,1])
            allow(board).to receive(:change_status)
            allow(board).to receive(:create_board)
            game.board = board
            game.white = white
            game.black = black
        end
        it "send message to create board" do
            expect(board).to receive(:create_board).once 
            game.set_up
        end
        it "send message to change square status" do 
            expect(board).to receive(:change_status).exactly(6).times
            game.set_up
        end
    end
    describe "#undo" do 
        rook = Rook.new(nil, nil)
        let(:board) { instance_double(Board) }
        let(:opponent) { instance_double(Player) }
        position = [1,1]
        destination = [1,8]

        context "when there is no removed piece" do 
            before do 
                game.removed_piece = nil
                allow(board).to receive(:change_status)
                allow(opponent).to receive(:pieces).and_return([])
                game.board = board
            end 
            it "change piece's position back to its initial position" do
                expect {game.undo(rook, position, destination, opponent) }.to change {rook.position}
                                                                        .from(nil)
                                                                        .to(position)
            end
            it "change position'status to piece" do 
                expect(board).to receive(:change_status).with(position, rook)
                game.undo(rook, position, destination, opponent)
                
            end
            it "change destination square's status to nil" do 
                expect(board).to receive(:change_status).with(destination, nil)
                game.undo(rook, position, destination, opponent)
                
            end
            it "do not touch opponent's piece" do 
                expect(opponent).not_to receive(:pieces)
                game.undo(rook, position, destination, opponent)
            end
        end
        context "when there is a removed piece like a bishop" do
            let(:bishop) { double('Bishop', position: [2,3]) } 
            before do 
                game.removed_piece = bishop
                allow(board).to receive(:change_status)
                allow(opponent).to receive(:pieces).and_return([])
                game.board = board
            end 
            it "restore opponent's pieces" do 
                expect { game.undo(rook, position, destination, opponent )}.to change { opponent.pieces.length }.by(1)
            end
            it "change removed piece's square status" do 
                #expect(board).to receive(:change_status).exactly(3).times
                expect(board).to receive(:change_status).with([2,3], bishop)
                game.undo(rook, position, destination, opponent)
            end
        end  
    end

    describe "#pawn_promote" do 
        let(:pawn) { instance_double(Pawn, position: [1,8]) }
        let(:player) { instance_double(Player) }
        let(:board) { instance_double(Board) }
        
        context "when true" do 
            let(:queen) { double(Queen, position: [1,8]) }
            before do 
                allow(pawn).to receive(:promote?).and_return('Q')
                allow(player).to receive_message_chain(:pieces, :delete).with(pawn)
               
                allow(player).to receive(:promote).and_return(queen)
                allow(board).to receive(:change_status) 

                game.board = board
            end
            it "delete own pawn" do 
                expect(player).to receive_message_chain(:pieces, :delete).with(pawn)
                game.pawn_promote(player, pawn)
            end
            it "make new piece" do 
                expect(player).to receive(:promote).with('Q', [1,8])
                game.pawn_promote(player, pawn)
            end
            it "adjust the square's status" do 
                expect(board).to receive(:change_status).with([1,8], queen)
                game.pawn_promote(player, pawn)
            end
        end
        context "when false" do 
            before do 
                allow(pawn).to receive(:promote?).and_return(nil)
                allow(player).to receive_message_chain(:pieces, :delete).with(pawn)
               
                allow(player).to receive(:promote)
                allow(board).to receive(:change_status) 

                game.board = board
            end
            it "do not delete pawn" do 
                expect(player).not_to receive(:pieces)
                game.pawn_promote(player, pawn)
            end
            it "do not make new piece" do 
                expect(player).not_to receive(:promote)
                game.pawn_promote(player, pawn)
            end
            it "do not adjust the square's status" do 
                expect(board).not_to receive(:change_status)
                game.pawn_promote(player, pawn)
            end
        end
    end
    describe "#modify_in_passing" do 
        let(:player) { double('Player', color: 'w') }
        context "when there is no in-passing piece" do 
            before do 
                game.in_passing = nil
            end
            it "@in_passing still equals nil" do 
                expect { game.modify_in_passing(player) }.not_to change { game.in_passing }
            end
        end
        context "when there is in-pssing piece and it has the same color with player" do 
        let(:pawn) { double('Pawn', color: 'w') }
            before do 
                game.in_passing = pawn
            end
            it "do not touch @in_passing variable" do 
                expect { game.modify_in_passing(player) }.not_to change { game.in_passing }
            end
        end
        context "when there is in-pssing piece and it has the different color with player" do 
            let(:pawn) { double('Pawn', color: 'b') } 
            before do  
                game.in_passing = pawn
            end
            it "set it to nil" do 
                expect { game.modify_in_passing(player) }.to change { game.in_passing }
                                                            .to(nil)
            end
        end
    end
    describe "#tie?" do  
        let(:attack) { double("Player", color: 'b') }
        let(:defense) { double("Player", color: 'w') }
        let(:king) { double("King", position: [2,2], name: 'K') }
        let(:queen) { double("Queen", name: 'Q')}
        let(:pawn) { double('Pawn', name: 'p', position: [1,2]) }
        let(:board) { double("Board") }
        context "when the king is checked" do 
            before do 
                #king is checked
                allow(defense).to receive(:get_piece).and_return([king])
                allow(game).to receive(:is_eaten_by).and_return(['bishop', 'knight'], ['queen'], ['pawn']) #[checked-pieces, attack-piece-on-the way king runs]
                #king has no way to go 
                allow(king).to receive(:generate_possible_coors).and_return([[1,2], [2,1]])
                #other pieces has no way to go
                allow(defense).to receive(:pieces).and_return([king, queen, pawn])
                allow(queen).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(pawn).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(game).to receive(:pass_basic_condition).and_return(false, false, false, true)
                allow(game).to receive(:pawn_valid_move).and_return(false, false)
                game.board = board
            end
            it "return false" do 
                expect(game.tie?(attack, defense)).to eq false
            end
        end
        context "when the king is not checked" do 
            before do 
                allow(defense).to receive(:get_piece).and_return([king])
                allow(defense).to receive(:pieces).and_return([king, queen, pawn])
                allow(king).to receive(:generate_possible_coors).and_return([[1,2], [2,1]])
                game.board = board
            end
            it "return false when king still has way to escape" do 
                #king is not checked
                #king still has a way to go
                allow(game).to receive(:is_eaten_by).and_return([], [], ['rook']) #[checked-pieces, attack-piece-on-the way king runs]
                #other pieces has no way to go 
                allow(queen).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(pawn).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                #can't move queen or pawn
                allow(game).to receive(:pass_basic_condition).and_return(false)
                allow(game).to receive(:pawn_valid_move).and_return(false) #cannot move any pawn
                
                expect(game.tie?(attack, defense)).to eq false
            end
            it "return false when we can move defense's pawn" do 
                #king is not checked
                #king still has no way to go
                allow(game).to receive(:is_eaten_by).and_return([], ['queen'], ['rook']) 
                #we can't move defense's queen
                allow(queen).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(game).to receive(:pass_basic_condition).and_return(false, false, false, true)
                #can move a pawn
                allow(pawn).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(game).to receive(:pawn_valid_move).and_return(false, true) #we can move a pawn
                expect(game.tie?(attack, defense)).to eq false
            end
            it "return false when we can move defense's queen" do 
                allow(game).to receive(:is_eaten_by).and_return([], ['queen'], ['rook'])
                #can move the queen
                allow(queen).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(game).to receive(:pass_basic_condition).and_return(false, true, false, false)
                allow(pawn).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                #we can't move the pawn
                allow(game).to receive(:pawn_valid_move).and_return(false, false) 
                
                expect(game.tie?(attack, defense)).to eq false
            end
            it "return 'tie' when king has no way to go and we can not move other pieces" do 
                allow(game).to receive(:is_eaten_by).and_return([], ['queen'], ['rook']) #king has no way to go
                allow(queen).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(pawn).to receive(:generate_possible_coors).and_return([[3,4], [3,5]])
                allow(game).to receive(:pass_basic_condition).and_return(false)
                allow(game).to receive(:pawn_valid_move).and_return(false) #can't move the pawn
                allow(board).to receive_message_chain(:get_square, :status, :color).and_return('w') #can't move the queen
                expect(game.tie?(attack, defense)).to eq 'tie'
            end
        end
    end
    describe "#is_checkmated?" do 
        let(:attack) { double('Player') }
        let(:defense) { double('Player', color: 'w') }
        let(:king) { double('King', position: [6,1], name: 'K') }
        let(:board) { double('Board') }
        let(:queen) { double('Queen', name: 'Q', position: [6,4]) }
        let(:knight) { double('Knight', name: 'N', position: [3,4]) }
        let(:pawn) { double('Pawn', name: 'p', position: [1,2]) }
        context "return false when" do 
            before do 
                allow(defense).to receive(:get_piece).and_return([king])
                game.board = board
            end
            it "the king can run when there is only one attacking piece" do
                #king is attacked by knight/pawn/queen and knight/pawn/queen can't be eaten 
                allow(game).to receive(:is_eaten_by).and_return([knight], [], [pawn], [] ) #[attack-piece, attack-piece_is eaten by?, king_run]
                #king can't be shieled if attacking piece is queen
                allow(queen).to receive(:coor_between).and_return([[6,2], [6,3]])
                allow(defense).to receive(:pieces).and_return([king, knight, queen, pawn])
                allow(game).to receive(:pass_basic_condition).and_return(false)
                ####
                #king can escape: 
                    #do not get checked if go 
                allow(king).to receive(:generate_possible_coors).and_return([[1,1], [1,2]]) 
                    #not totally surrounded by own pieces
                allow(board).to receive(:get_status_color).and_return(nil, 'b') 
                ######
                expect(game.is_checkmated?(attack, defense)).to eq false
            end
            it "the king can run when there are two attacking pieces" do 
                #king is attacked by two pieces and it doesn't matter whether one of them can be eaten
                allow(game).to receive(:is_eaten_by).and_return([knight, queen], []) #[attack-piece, attack-piece_is eaten by?, king_run]
                #king can escape: 
                    #do not get checked if go 
                allow(king).to receive(:generate_possible_coors).and_return([[1,1], [1,2]]) 
                    #not totally surrounded by own pieces
                allow(board).to receive(:get_status_color).and_return('w', 'b') 
                ######
                expect(game.is_checkmated?(attack, defense)).to eq false
            end
            it "we can eat the attack piece" do 
                #king is attacked by knight/pawn/queen and knight/pawn/queen can be eaten 
                allow(game).to receive(:is_eaten_by).and_return([queen], [queen]) #[attack-piece, attack-piece_is eaten by?, king_run]
                #king can't be shielded if attacking piece is queen
                allow(queen).to receive(:coor_between).and_return([[6,2], [6,3]])
                allow(defense).to receive(:pieces).and_return([knight, king, queen, pawn])
                allow(game).to receive(:pass_basic_condition).and_return(false)
                ####
                #king has no way to go because 
                    #get checked if go / do not get check
                allow(king).to receive(:generate_possible_coors).and_return([[1,1], [1,2]]) 
                    #not surround by own pieces / surrounded
                allow(board).to receive(:get_status_color).and_return('w') 
                ######
                expect(game.is_checkmated?(attack, defense)).to eq false
            end
            it "we can shield the king with another piece" do 
                 #king is attacked by knight/pawn/queen and knight/pawn/queen can't be eaten 
                 allow(game).to receive(:is_eaten_by).and_return([queen], [], []) #[attack-piece, attack-piece_is eaten by?, king_run]
                 #king can be shielded if attacking piece is queen
                 allow(queen).to receive(:coor_between).and_return([[6,2], [6,3]])
                 allow(defense).to receive(:pieces).and_return([knight, king, queen, pawn])
                 allow(game).to receive(:pass_basic_condition).and_return(true)
                 allow(game).to receive(:pawn_valid_move).and_return(false)
                 allow(knight).to receive(:path_valid?).and_return(false)
                 allow(queen).to receive(:path_valid?).and_return(false, true)
                ####
                #king has no way to go because 
                    #get checked if go / do not get check
                allow(king).to receive(:generate_possible_coors).and_return([[1,1], [1,2]]) 
                #not surround by own pieces / surrounded
                allow(board).to receive(:get_status_color).and_return('w')
                ###### 
                expect(game.is_checkmated?(attack, defense)).to eq false
            end
        end
        context "when king is checked and cannot run" do 
            before do 
                allow(defense).to receive(:get_piece).and_return([king])
                game.board = board
            end
            it "return true when king is checked by more than two pieces and can not run" do 
                #king is attacked by two pieces and it doesn't matter whether one of them can be eaten
                allow(game).to receive(:is_eaten_by).and_return([knight, queen], [pawn]) #[attack-piece, attack-piece_is eaten by?, king_run]
                #king has no way to go because 
                    #get checked if go / do not get check
                allow(king).to receive(:generate_possible_coors).and_return([[1,1], [1,2]]) 
                    #not surround by own pieces / surrounded
                allow(board).to receive(:get_status_color).and_return('w', 'b')
                ###### 
                expect(game.is_checkmated?(attack, defense)).to eq true
            end
            it "return true when king is checked by one piece and we can't shield, eat or run" do 
                #king is attacked by knight/pawn/queen and knight/pawn/queen can't be eaten 
                allow(game).to receive(:is_eaten_by).and_return([queen], [], [pawn]) #[attack-piece, attack-piece_is eaten by?, king_run]
                #king can't be shielded if attacking piece is queen
                allow(queen).to receive(:coor_between).and_return([[6,2], [6,3]])
                allow(defense).to receive(:pieces).and_return([knight, king, queen, pawn])
                
                allow(game).to receive(:pawn_valid_move).and_return(false)
                allow(knight).to receive(:path_valid?).and_return(false)
                allow(queen).to receive(:path_valid?).and_return(false)
                ####
                #king has no way to go because 
                    #get checked if go / do not get check
                allow(king).to receive(:generate_possible_coors).and_return([[1,1], [1,2]]) 
                    #not surround by own pieces / surrounded
                allow(board).to receive(:get_status_color).and_return(nil, 'w') 
                ######
                expect(game.is_checkmated?(attack, defense)).to eq true
            end
        end
    end
    describe "#pawn_valid_move" do 
        let(:opponent) { double('Player') }
        let(:pawn) { double('Pawn') }
        let(:board) { double('Board') }
        context "when move 1 step forward" do 
            before do 
                allow(pawn).to receive(:get_direction).and_return([0,-1])
                allow(pawn).to receive(:move_pattern?).and_return(true)
                allow(board).to receive(:get_status).and_return(nil)
                game.board = board
            end
            it "return true" do 
                expect(game.pawn_valid_move(pawn, [2,6], [2,3], opponent)).to eq true
            end
        end
        context "when move 2 steps forward" do 
            before do 
                allow(pawn).to receive(:get_direction).and_return([0,-2])
                allow(pawn).to receive(:move_pattern?).and_return(true)
                allow(pawn).to receive(:initial_position?).and_return(true)
                allow(pawn).to receive(:coor_between).and_return([2,5])
                allow(board).to receive(:get_status).and_return(nil, nil)
                game.board = board
            end
            it "send in-passing signal" do 
                expect(game.pawn_valid_move(pawn, [2,6], [2,4], opponent)).to eq pawn
            end
        end
        context "when eat normally" do 
            before do 
                allow(pawn).to receive(:get_direction).and_return([1,-1])
                allow(pawn).to receive(:move_pattern?).and_return(true)
                allow(board).to receive(:get_status).and_return('pawn')
                game.board = board
            end
            it "return true" do 
                expect(game.pawn_valid_move(pawn, [2,6], [3,5], opponent)).to eq true
            end 
        end
        context "when eat in-passing pawn" do 
            let(:in_passing_pawn) { double('Pawn') }
            before do 
                allow(pawn).to receive(:get_direction).and_return([1,-1])
                allow(pawn).to receive(:move_pattern?).and_return(true)
                allow(board).to receive(:get_status).and_return(nil)
                allow(opponent).to receive(:get_piece).and_return(in_passing_pawn)
                game.in_passing = in_passing_pawn
                game.board = board
            end
            it "return eaten in-passing pawn" do 
                expect(game.pawn_valid_move(pawn, [2,6], [3,5], opponent)).to eq in_passing_pawn
            end
            it "send the right coordinator of in-passing pawn" do 
                expect(opponent).to receive(:get_piece).with('p', [3, 6])
                game.pawn_valid_move(pawn, [2,6], [3,5], opponent)
            end
        end
        context "when move one step forward but there is obstacle" do 
            before do 
                allow(pawn).to receive(:get_direction).and_return([0,-1])
                allow(pawn).to receive(:move_pattern?).and_return(true)
                allow(board).to receive(:get_status).and_return('rook')
                game.board = board
            end
            it "return false" do 
                expect(game.pawn_valid_move(pawn, [2,2], [2,3], opponent)).to eq false
            end
        end
        context "when move 2 steps forward" do 
            before do 
                allow(pawn).to receive(:get_direction).and_return([0,-2])
                allow(pawn).to receive(:move_pattern?).and_return(true)
                allow(pawn).to receive(:coor_between).and_return([2,5])
                game.board = board
            end
            it "return false when not be at initial position" do 
                allow(board).to receive(:get_status).and_return(nil, nil)
                allow(pawn).to receive(:initial_position?).and_return(false)
                expect(game.pawn_valid_move(pawn, [2,2], [2,4], opponent)).to eq false
            end
            it "return false when there is obstacle" do 
                allow(board).to receive(:get_status).and_return('queen', nil)
                allow(pawn).to receive(:initial_position?).and_return(true)
                expect(game.pawn_valid_move(pawn, [2,2], [2,4], opponent)).to eq false
            end
        end
        context "when move-pattern is eating but there's no piece to eat" do 
            before do 
                allow(pawn).to receive(:get_direction).and_return([1,-1])
                allow(pawn).to receive(:move_pattern?).and_return(true)
                allow(board).to receive(:get_status).and_return(nil)
                #allow(opponent).to receive(:get_piece).and_return(nil)
                game.in_passing = nil #/'pawn'
                game.board = board
            end 
            it "return false" do 
                expect(game.pawn_valid_move(pawn, [2,6], [3,5], opponent)).to eq false
            end
        end
    end
    describe "#ask" do 
        let(:player) { double('Player', color: 'w') }
        it "when user input is 'a2-a3' return ['a','2','-','a','3']" do 
            allow(game).to receive(:puts)
            allow(game).to receive(:gets).and_return("a2-a3")
            expect(game.ask(player)).to eq ['a','2','-','a','3']
        end
        it "when user input is 'Qh3-Qh7' return ['Q','h','3','-','Q','h','7']" do 
        end 
    end
    #haven't tested the two methods below
    describe "#castle_succeed?" do 
        context "castling in the king side for white player" do 
        end
        context "castling in the queen side for the queen player" do 
        end
        context "castling in the king side for the black player" do 
        end
        context "castling in the queen side for the black player" do 
        end
    end
    describe "#change" do 
        context "when piece is pawn and it moves 2 steps forward" do 
        end
    end
    
 end

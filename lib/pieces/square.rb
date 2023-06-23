class Square 
    attr_reader :coordinator
    attr_accessor :status
    def initialize(coordinator, status=nil)
        @coordinator = coordinator
        @status = status
    end
end
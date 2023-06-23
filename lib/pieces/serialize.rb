require 'yaml'
module BasicSerialize
    @@serializer = YAML
    def serialize 
        obj = instance_variables.inject(Hash.new) do |h, var_name|
            h[var_name] = instance_variable_get(var_name)
            h 
        end
        @@serializer.dump obj
    end
    
    def piece_unserialize(piece_data)
        hash = @@serializer.load(piece_data)
        case hash[:@name]
        when 'K'
            piece = King.new(nil, nil)
        when 'Q'
            piece = Queen.new(nil, nil)
        when 'N'
            piece = Knight.new(nil, nil)
        when 'B'
            piece = Bishop.new(nil, nil)
        when 'R'
            piece = Rook.new(nil, nil)
        else 
            piece = Pawn.new(nil, nil)
        end
        
        hash.each do |k,v|
            piece.instance_variable_set(k,v)
        end
        piece
    end
end
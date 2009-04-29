
module DataMapper::Types
  class Href < DataMapper::Type
    primitive String
    length 255
    
    def self.load(value, property)
      value
    end

    def self.dump(value, property)
      value
    end

    def self.typecast(value, property)
      value
    end
  end
end

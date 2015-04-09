class ::Symbol
  class << self
    def to_ruby( other )
      other.to_sym
    end
  end
end
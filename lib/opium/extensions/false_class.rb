class FalseClass
  include Boolean
  
  def to_bool
    self
  end
  
  class << self
    
  end
end
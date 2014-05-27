class FalseClass
  include Boolean
  
  def to_bool
    self
  end
end
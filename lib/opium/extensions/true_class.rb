class TrueClass
  include Opium::Boolean
  
  def to_bool
    self
  end
end
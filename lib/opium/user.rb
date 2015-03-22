module Opium
  class User
    include Opium::Model
    
    field :username, type: String
    field :password, type: String
    field :email, type: String
    field :email_verified, type: Boolean
    
    def self.authenticate( username, password )
      
    end
        
    def reset_password
      
    end
  end
end
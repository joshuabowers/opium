module Opium
  class User
    include Opium::Model
    
    field :username, type: String
    field :password, type: String
    field :email, type: String
    field :email_verified, type: Boolean
    field :session_token, type: String, readonly: true
    
    no_object_prefix!
    
    class << self
      def authenticate( username, password )
      
      end
    
      def authenticate!( username, password )
      
      end
    end
            
    def reset_password
      
    end
  end
end
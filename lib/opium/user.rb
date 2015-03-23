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
      # Note that this will eat any ParseErrors which get raised, and not perform any logging.
      def authenticate( username, password )
        authenticate!( username, password )
      rescue Opium::Model::Connectable::ParseError => e
        nil
      end
    
      def authenticate!( username, password )
        new( as_resource('login') { http_get query: { username: username, password: password } } )
      end
    end
    
    def reset_password
      reset_password!
    rescue => e
      self.errors.add( :email, e.to_s )
      false
    end
    
    def reset_password!
      fail KeyError, 'an email address is required to reset password' unless email
      self.class.as_resource('requestPasswordReset') { self.class.http_post data: email }.empty?
    end
  end
end
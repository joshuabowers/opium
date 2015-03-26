module Opium
  module Model
    module Inheritable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def inherited( subclass ) 
          subclass.fields.merge!( self.fields )
        end
      end
    end
  end
end
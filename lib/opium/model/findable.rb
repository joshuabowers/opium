module Opium
  module Model
    module Findable
      extend ActiveSupport::Concern
      
      module ClassMethods
        def find( id )
          new self.http_get( id: id )
        end
        
        delegate \
          :first,
          :each,
          :each_with_index,
          :map,
          to: :criteria
      end
    end
  end
end
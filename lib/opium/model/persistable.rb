module Opium
  module Model
    module Persistable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods
        def destroy_all( query = nil )
          
        end
        
        def delete_all( query = nil )
          
        end
      end
      
      def save( options = {} )
        if !options[:validates] || valid?
          if new_record?
            create
          else
            update
          end
        end && true
      end
      
      def destroy
        
      end
      
      def delete
        
      end
      
      def new_record?
        self.id.nil?
      end
      
      def persisted?
        !self.changed?
      end
      
      private
      
      # Problem which needs addressing: both create and update need to be able to obtain a set of parse converted
      # attributes to pass over the HTTP channel. This would require both to use the parse names for the associated
      # fields, as well as the to_parse converted values for those fields.
      def create
        self.attributes = self.class.http_post self.to_json( except: [:id, :created_at, :updated_at] )
      end
      
      def update
        # self.attributes = self.class.http_put self.to_json( except: [:id, :created_at, :udpated_at] )
      end
    end
  end
end
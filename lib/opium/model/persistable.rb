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
      
      def delete
        self.tap do
          self.class.http_delete id unless new_record?
          self.freeze
        end
      end
      alias_method :destroy, :delete
      
      def new_record?
        self.id.nil?
      end
      
      def persisted?
        !new_record? && !self.changed?
      end
      
      private
      
      def create
        self.attributes = self.class.http_post self.attributes_to_parse( except: [:id, :created_at, :updated_at] )
      end
      
      def update
        self.attributes = self.class.http_put id, self.attributes_to_parse( only: changes.keys )
      end
    end
  end
end
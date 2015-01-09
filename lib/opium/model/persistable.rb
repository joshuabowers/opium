module Opium
  module Model
    module Persistable
      extend ActiveSupport::Concern
      
      included do
      end
      
      class InvalidError < StandardError
      end
      
      module ClassMethods
        def create( attributes = {} )
          new( attributes ).tap {|model| model.save}
        end
        
        def create!( attributes = {} )
          new( attributes ).tap {|model| model.save!}
        end
        
        def destroy_all( query = nil )
          
        end
        
        def delete_all( query = nil )
          
        end
      end
      
      def save( options = {} )
        create_or_update( options )
      rescue Exception => e
        errors.add( :base, e.to_s )
        false
      end
      
      def save!
        create_or_update( validates: true ) || raise( InvalidError, 'failed to save, as model is invalid' )
      end
      
      def update_attributes( attributes = {} )
        self.attributes = attributes
        save
      end
      
      def update_attributes!( attributes = {} )
        self.attributes = attributes
        save!
      end
      
      def touch
        save( validates: false )
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
      
      def pointer
        @pointer ||= Pointer.new( model: self.class, id: id ) unless new_record?
      end
      
      def to_parse
        pointer.to_parse
      end
      
      private
      
      def create_or_update( options )
        if options[:validates] == false || valid?
          if new_record?
            create
          else
            update
          end
        end.present?
      end
      
      def create
        self.attributes = self.class.http_post self.attributes_to_parse( except: [:id, :created_at, :updated_at] )
      end
      
      def update
        self.attributes = self.class.http_put id, self.attributes_to_parse( only: changes.keys )
      end
    end
  end
end
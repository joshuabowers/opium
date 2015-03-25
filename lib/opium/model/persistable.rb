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
        
        def added_headers
          @added_headers ||= {}.with_indifferent_access
        end
        
        def add_header_to( methods, header, value, options = {} )
          Array( methods ).each do |method|
            added_headers[method] = { header: header, value: value, options: options }
            
            added_headers[method][:options][:only] = Array( options[:only] )
            added_headers[method][:options][:except] = Array( options[:except] )
          end
          nil
        end
        
        def get_header_for( method, context, owner = nil )
          return {} unless added_headers[method]
          
          eval_only = !added_headers[method][:options][:only].empty?
          eval_except = !added_headers[method][:options][:except].empty?
          
          within_only = added_headers[method][:options][:only].include?( context )
          within_except = added_headers[method][:options][:except].include?( context )
          
          value = added_headers[method][:value]
          value = value.call( owner ) if owner && value.respond_to?( :call )
          
          if value && ( ( !eval_only && !eval_except ) || ( eval_only && within_only ) || ( eval_except && !within_except ) )
            { headers: { added_headers[method][:header] => value } } 
          else
            {}
          end
        end
      end
      
      def save( options = {} )
        create_or_update( options )
      rescue => e
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
          headers = self.class.get_header_for( :delete, :delete, self )
          self.class.http_delete id, headers unless new_record?
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
            create( options )
          else
            update( options )
          end
        end.present?
      end
      
      def create( options = {} )
        # headers = options.deep_merge self.class.get_header_for( :post, :create, self )
        # result = self.class.http_post self.attributes_to_parse( except: [:id, :created_at, :updated_at] ), headers
        self.attributes = attributes_or_headers( :post, :create, options ) do |headers|
          self.class.http_post self.attributes_to_parse( except: [:id, :created_at, :updated_at] ), headers
        end
      end
      
      def update( options = {} )
        # self.attributes = self.class.http_put id, self.attributes_to_parse( only: changes.keys ), headers
        self.attributes = attributes_or_headers( :put, :update, options ) do |headers|
          self.class.http_put id, self.attributes_to_parse( only: changes.keys ), headers
        end
      end
      
      def sent_headers
        @_sent_headers || {}
      end
      
      def attributes_or_headers( method, action, options, &block )
        result = block.call( options.deep_merge self.class.get_header_for( method, action, self ) )
        if options[:sent_headers]
          @_sent_headers = result
          {}
        else
          result
        end 
      end
    end
  end
end
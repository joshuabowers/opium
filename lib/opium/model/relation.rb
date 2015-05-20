module Opium
  module Model
    class Relation < Criteria
      include ActiveModel::Dirty
      
      class << self
        def to_parse( object )
          class_name =
            case object
            when Hash
              fetch_hash_key_from( object, 'class_name' ) || fetch_hash_key_from( object, 'model_name' )
            when String, Symbol
              object
            when is_descendant.curry[Opium::Model]
              object.model_name
            when self
              object.class_name
            else
              fail ArgumentError, "could not convert #{ object.inspect } to a parse Relation hash"
            end
          fail ArgumentError, "could not determine class_name from #{ object.inspect }" unless class_name
          { __type: 'Relation', className: class_name }.with_indifferent_access
        end
        
        def to_ruby( object )
          return if object.nil?
          return object if object.is_a? self
          class_name = 
            case object
            when Hash
              fetch_hash_key_from( object, 'class_name' ) || fetch_hash_key_from( object, 'model_name' )
            when String, Symbol
              object
            when is_descendant.curry[Opium::Model]
              object.model_name
            else
              fail ArgumentError, "could not convert #{ object.inspect } to a Opium::Model::Relation"
            end
          new( class_name )
        end
        
        private
        
        def is_descendant
          @is_descendant ||= ->( expected_type, object ) { ( object.is_a?( Class ) ? object : object.class ) <= expected_type }
        end
        
        def fetch_hash_key_from( hash, key )
          snake_case_key = key.to_s.underscore
          lower_camel_key = key.to_s.camelcase(:lower)
          
          hash[ snake_case_key ] || hash[ snake_case_key.to_sym ] || hash[ lower_camel_key ] || hash[ lower_camel_key.to_sym ]
        end
      end
      
      def initialize( model_name )
        super
        update_variable!( :cache, true )
      end
      
      def to_parse
        self.class.to_parse self
      end
      
      def empty?
        owner.nil? || owner.new_record? ? true : super
      end
      
      attr_reader :owner, :metadata
      
      def owner=(value)
        @owner = value
        update_constraint!( :where, '$relatedTo' => { 'object' => value.to_parse } )
      end
      
      def metadata=(value)
        @metadata = value
        update_constraint!( :where, '$relatedTo' => { 'key' => value.relation_name.to_s } )
      end
      
      alias_method :class_name, :model_name
      
      #TODO: likely will need to reimplement .each
      
      def each(&block)
        if !block_given?
          to_enum(:each)
        else
          super() {|model| block.call( model ) unless __deletions__.include?( model ) }
          (__additions__ - __deletions__).each(&block)
        end
      end
      
      def push( object )
        __additions__.push( object )
        self
      end
      
      alias_method :<<, :push
      
      def delete( object )
        __deletions__.push( object )
        self
      end
      
      def build( params = {} )
        model.new( params || {} ).tap do |instance|
          push instance
        end
      end
      
      alias_method :new, :build
      
      def save
        self.reject {|model| model.persisted?}.each(&:save)
        __apply_additions__
        __apply_deletions__
        true
      end
      
      def parse_response
        @parse_response ||= []
      end
      
      private
      
      def __relation_deltas__
        @__relation_deltas__ ||= {}
      end
      
      def __additions__
        __relation_deltas__[:additions] ||= []
      end
      
      def __deletions__
        __relation_deltas__[:deletions] ||= []
      end
      
      def __apply_additions__
        unless __additions__.empty?
          parse_response << owner.class.http_put( owner.id, { metadata.relation_name => { __op: 'AddRelation', objects: __additions__.map(&:to_parse) } } )
          @cache.concat( __additions__ )
          __additions__.clear
        end
      end
      
      def __apply_deletions__
        unless __deletions__.empty?
          parse_response << owner.class.http_put( owner.id, { metadata.relation_name => { __op: 'RemoveRelation', objects: __deletions__.map(&:to_parse) } } )
          @cache = @cache - __deletions__
          __deletions__.clear
        end
      end
    end
  end
end
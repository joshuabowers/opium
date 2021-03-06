require 'mimemagic'
require 'opium/model/connectable'

module Opium
  class File
    include Opium::Model::Connectable
    
    no_object_prefix!
    
    class << self
      def model_name
        @model_name ||= ActiveModel::Name.new( self )
      end
      
      def upload( file, options = {} )
        request_options = build_request_options( file, options )
        attributes = send( :http, :post, request_options ) do |request|
          request.body = Faraday::UploadIO.new( file, request_options[:headers][:content_type] )
        end
        options[:sent_headers] ? attributes : new(attributes)
      end
      
      def to_ruby( object )
        return if object.nil? || object == ''
        return object if object.is_a?( self )
        object = ::JSON.parse( object ) if object.is_a?( String )
        if object.is_a?( Hash ) && (has_key_of_value( object, :__type, 'File' ) || has_keys( object, :url, :name ))
          new( object )
        else
          fail ArgumentError, "could not convert #{ object.inspect } to an Opium::File" 
        end
      end
      
      def to_parse( object )
        return unless object
        fail ArgumentError, "could not convert #{ object.inspect } to a Parse File object" unless object.is_a?( self ) && object.name
        {
          __type: 'File',
          name: object.name
        }.with_indifferent_access
      end
      
      private
      
      # Note that MimeMagic returns application/zip for the more recent MS Office file types,
      # hence the extra check.
      def build_request_options( file, options )
        {}.tap do |result|
          mime_type = options.fetch( :content_type, MimeMagic.by_magic(file) )
          mime_type = MimeMagic.by_path(file) if mime_type == 'application/zip'
          result[:id] = parameterize_name( options[:original_filename] || ::File.basename( file ) )
          result[:headers] = { content_type: mime_type.to_s, content_length: file.size.to_s }
          result[:sent_headers] = options[:sent_headers] if options.key? :sent_headers
        end
      end
      
      def has_key_of_value( object, key, value )
        (object[key] || object[key.to_s]) == value
      end
      
      def has_keys( object, *keys )
        object.keys.all? {|key| keys.include?( key.to_s ) || keys.include?( key.to_sym )}
      end
      
      def parameterize_name( name )
        without_extension, extension = ::File.basename( name, '.*' ), ::File.extname( name )
        without_extension.parameterize + extension
      end
    end
    
    def initialize( attributes = {} )
      attributes.with_indifferent_access.each do |k, v|
        send( :"#{k}=", v ) unless k == '__type'
      end
    end
    
    def delete( options = {} )
      fail "cannot delete #{ self.inspect }, as there is no name" unless self.name
      self.class.with_heightened_privileges do
        self.class.http_delete self.name, options
      end.tap { self.freeze }
    end
    
    attr_reader :name, :url
    
    def mime_type
      @mime_type ||= MimeMagic.by_path( url ) if url
    end
    
    def inspect
      "#<#{ self.class.model_name.name } name=#{ name.inspect } url=#{ url.inspect } mime_type=#{ (mime_type ? mime_type.type : nil).inspect }>"
    end
    
    def to_parse
      self.class.to_parse( self )
    end
    
    private
    
    attr_writer :name, :url
  end
end
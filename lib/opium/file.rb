require 'mimemagic'

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
      
      private
      
      # Note that MimeMagic returns application/zip for the more recent MS Office file types,
      # hence the extra check.
      def build_request_options( file, options )
        {}.tap do |result|
          mime_type = options.fetch( :content_type, MimeMagic.by_magic(file) )
          mime_type = MimeMagic.by_path(file) if mime_type == 'application/zip'
          result[:id] = options[:original_filename] || ::File.basename( file )
          result[:headers] = { content_type: mime_type.to_s }
          result[:sent_headers] = options[:sent_headers] if options.key? :sent_headers
        end
      end
    end
    
    def initialize( attributes = {} )
      attributes.with_indifferent_access.each do |k, v|
        send( :"#{k}=", v ) unless k == '__type'
      end
    end
    
    def delete( options = {} )
      
    end
    
    attr_reader :name, :url
    
    def mime_type
      @mime_type ||= MimeMagic.by_path( url ) if url
    end
    
    def inspect
      "#<#{ self.class.model_name.name } name=#{ name.inspect } url=#{ url.inspect } mime_type=#{ (mime_type ? mime_type.type : nil).inspect }>"
    end
    
    private
    
    attr_writer :name, :url
  end
end
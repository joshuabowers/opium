require 'faraday'
require 'faraday_middleware'

module Opium
  module Model
    module Connectable
      extend ActiveSupport::Concern
      
      included do
      end
      
      class ParseError < StandardError
        def initialize( code, error )
          super( error )
          @code = code
        end
        
        attr_reader :code
      end
      
      module ClassMethods
        def connection
          @@connection ||= Faraday.new( url: 'https://api.parse.com/1/' ) do |faraday|
            faraday.request :multipart
            faraday.request :url_encoded
            faraday.response :logger if Opium.config.log_network_responses
            faraday.response :json, content_type: /\bjson$/
            faraday.headers['X-Parse-Application-Id'] = Opium.config.app_id
            faraday.headers['X-Parse-REST-API-Key'] = Opium.config.api_key
            faraday.adapter Faraday.default_adapter
          end
        end
        
        def reset_connection!
          @@connection = nil
        end
        
        def object_prefix
          @object_prefix ||= 'classes'
        end
        
        # Parse doesn't route User objects through /classes/, instead treating them as a top-level class.
        def no_object_prefix!
          @object_prefix = ''
        end
        
        def as_resource( name, &block )
          fail ArgumentError, 'no block given' unless block_given?
          @masked_resource_name = name.to_s.freeze
          block.call
        ensure
          @masked_resource_name = nil
        end
        
        def resource_name( resource_id = nil )
          return @masked_resource_name if @masked_resource_name
          @resource_name ||= Pathname.new( object_prefix ).join( map_name_to_resource( model_name ) )
          ( resource_id ? @resource_name.join( resource_id ) : @resource_name ).to_s
        end
        
        def http_get( options = {} )
          http( :get, options ) do |request|
            options.fetch(:query, {}).each do |key, value|
              request.params[key] = key.to_s == 'where' ? value.to_json : value
            end
          end
        end
        
        def http_post( data, options = {} )
          http( :post, options, &infuse_request_with( data ) )
        end
        
        def http_put( id, data, options = {} )
          http( :put, {id: id}.merge(options), &infuse_request_with( data ) )          
        end
        
        def http_delete( id )
          http( :delete, id: id )
        end
        
        def requires_heightened_privileges!
          @requires_heightened_privileges = true
        end
        
        def requires_heightened_privileges?
          !@requires_heightened_privileges.nil?
        end
        
        private
                
        def http( method, options, &block )
          check_for_error( options ) do
            connection.send( method, resource_name( options[:id] ), &apply_headers_to_request( method, options, &block ) )
          end
        end
        
        def map_name_to_resource( model_name )
          name = model_name.name.demodulize
          @object_prefix.empty? ? name.tableize : name
        end
        
        def infuse_request_with( data )
          lambda do |request|
            request.headers['Content-Type'] = 'application/json'
            request.body = data
            request.body = request.body.to_json unless request.body.is_a?(String)
          end
        end
        
        def apply_headers_to_request( method, options, &further_operations )
          lambda do |request|
            if options[:headers]
              request.headers.merge! options[:headers]
            end
            if method != :get && requires_heightened_privileges? && Opium.config.master_key
              request.headers.merge!( x_parse_master_key: Opium.config.master_key ) 
              request.headers.delete :x_parse_rest_api_key
            end
            further_operations.call( request ) if block_given?
          end
        end
        
        def check_for_error( options = {}, &block )
          fail ArgumentError, 'no block given' unless block_given?
          result = yield
          unless options[:raw_response]
            result = result.body
            result = result.is_a?(Hash) ? result.with_indifferent_access : {}
            fail ParseError.new( result[:code], result[:error] ) if result[:code] && result[:error]
          end
          result
        end
      end
    end
  end
end
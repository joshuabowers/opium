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
        
        def resource_name( resource_id = nil )
          @resource_name ||= Pathname.new( object_prefix ).join( model_name.name.demodulize )
          ( resource_id ? @resource_name.join( resource_id ) : @resource_name ).to_s
        end
        
        def http_get( options = {} )
          http( :get, options ) do |request|
            options.fetch(:query, {}).each do |key, value|
              request.params[key] = key.to_s == 'where' ? value.to_json : value
            end
          end
        end
        
        def http_post( data )
          http( :post, {}, &infuse_request_with( data ) )
        end
        
        def http_put( id, data )
          http( :put, id: id, &infuse_request_with( data ) )          
        end
        
        def http_delete( id )
          http( :delete, id: id )
        end
        
        private
                
        def http( method, options, &block )
          check_for_error( options ) do
            connection.send( method, resource_name( options[:id] ), &block )
          end
        end
        
        def infuse_request_with( data )
          lambda do |request|
            request.headers['Content-Type'] = 'application/json'
            request.body = data
            request.body = request.body.to_json unless request.body.is_a?(String)
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
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
            faraday.response :logger if Opium.configuration.log_network_responses
            faraday.response :json, content_type: /\bjson$/
            faraday.headers['X-Parse-Application-Id'] = Opium.configuration.app_id
            faraday.headers['X-Parse-REST-API-Key'] = Opium.configuration.api_key
            faraday.adapter Faraday.default_adapter
          end
        end
        
        def object_prefix
          'classes'
        end
        
        def resource_name( resource_id = nil )
          @resource_name ||= "#{object_prefix}/#{model_name.camelize}"
          resource_id ? [@resource_name, resource_id].join('/') : @resource_name
        end
        
        def http_post( data )
          http( :post, data: data )
        end
        
        def http_put( data )
          http( :put, data: data )          
        end
        
        private
                
        def http( method, options )
          check_for_error do
            connection.send( method, resource_name( options[:id] ) ) do |request|
              if options[:query]
                options[:query].each do |key, value|
                  request.params[key] = value
                end
              end
              if [:post, :put].include? method
                request.headers['Content-Type'] = 'application/json'
                request.body = options[:data]
                request.body = request.body.to_json unless request.body.is_a?(String)
              end
            end
          end
        end
        
        def check_for_error(&block)
          raise ArgumentError, "no block given" unless block_given?
          result = yield.body.with_indifferent_access
          raise ParseError.new( result[:code], result[:error] ) if result[:code] && result[:error]
          result
        end
      end
    end
  end
end
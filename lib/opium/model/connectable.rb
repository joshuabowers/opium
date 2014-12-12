require 'faraday'

module Opium
  module Model
    module Connectable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods
        def connection
          @@connection ||= Faraday.new( url: 'https://api.parse.com/1/' ) do |faraday|
            faraday.request :multipart
            faraday.request :url_encoded
            faraday.response :logger
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
        
        # This is going to need to distinguish between two different usage scenarios:
        # 1) data is a resource id:
        # => in this scenario, the resource id should be passed off to #resource_name.
        # 2) data is a query:
        # => in this scenario, the query needs to be url-encoded and added as a param to the request.
        def http_get( options = {} )
          raise ArgumentError, "expecting either :id or :query" unless options[:id] || options[:query]
          check_for_error do
            connection.get resource_name( options[:id] ) do |request|
              if options[:query]
                options[:query].each do |key, value|
                  request.params[key] = value
                end
              end
            end
          end
        end
        
        def http_post
          check_for_error do
          end
        end
        
        def http_put
          check_for_error do
          end
        end
        
        def http_delete
          check_for_error do
          end
        end
        
        def check_for_error(&block)
          raise ArgumentError, "no block given" unless block_given?
          result = block.call.with_indifferent_access
          if result[:code] && result[:error]
          end
          result
        end
                        
        private :http_get, :http_post, :http_put, :http_delete
      end
    end
  end
end
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
            faraday.headers['X-Parse-Application-Id'] = "1234"
            faraday.headers['X-Parse-REST-API-Key'] = "1234"
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
        
        def http_get
          # connection.get 
        end
        
        def http_post
          
        end
        
        def http_put
          
        end
        
        def http_delete
          
        end
                        
        private :http_get, :http_post, :http_put, :http_delete
      end
    end
  end
end
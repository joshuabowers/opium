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
        def parse_server_url
          ::URI.join( ::Opium.config.server_url, ::Opium.config.mount_point ).to_s
        end

        def connection
          @@connection ||= Faraday.new( url: parse_server_url ) do |faraday|
            faraday.request :multipart
            faraday.request :url_encoded
            faraday.request :json
            faraday.response :logger if Opium.config.log_network_responses
            faraday.response :json, content_type: /\bjson$/
            faraday.headers[:x_parse_application_id] = Opium.config.app_id
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
          http( :post, deeply_merge( options, content_type_json ), &infuse_request_with( data ) )
        end

        def http_put( id, data, options = {} )
          http( :put, deeply_merge( options, content_type_json, id: id ), &infuse_request_with( data ) )
        end

        def http_delete( id, options = {} )
          http( :delete, deeply_merge( options, id: id ) )
        end

        def requires_heightened_privileges!
          @requires_heightened_privileges = true
        end

        def requires_heightened_privileges?
          !@requires_heightened_privileges.nil?
        end

        alias_method :has_heightened_privileges?, :requires_heightened_privileges?

        def with_heightened_privileges(&block)
          previous, @requires_heightened_privileges = @requires_heightened_privileges, true
          block.call if block_given?
        ensure
          @requires_heightened_privileges = previous
        end

        def no_really_i_need_master!
          @always_heightened_privileges = true
        end

        def has_a_master_complex?
          !@always_heightened_privileges.nil?
        end

        private

        def http( method, options, &block )
          check_for_error( options ) do
            if options[:sent_headers]
              applier = apply_headers_to_request( method, options, &block )
              request = connection.build_request( method )
              applier.call( request )
              request.headers
            else
              connection.send( method, resource_name( options[:id] ), &apply_headers_to_request( method, options, &block ) )
            end
          end
        end

        def deeply_merge( *args )
          args.reduce {|a, e| a.deep_merge e }
        end

        def content_type_json
          @content_type_json ||= { headers: { content_type: 'application/json' } }
        end

        def map_name_to_resource( model_name )
          name = model_name.name.demodulize
          @object_prefix.empty? ? name.tableize : name
        end

        def infuse_request_with( data )
          lambda do |request|
            request.body = data
          end
        end

        def apply_headers_to_request( method, options, &further_operations )
          lambda do |request|
            request.headers.update options[:headers] if options[:headers]

            if use_master_key?( request, method )
              request.headers[:x_parse_master_key] = Opium.config.master_key
            else
              request.headers[:x_parse_rest_api_key] = Opium.config.api_key
            end

            further_operations.call( request ) if block_given?
          end
        end

        def use_master_key?( request, method )
          !request.headers[:x_parse_session_token] &&
          ( @always_heightened_privileges || method != :get ) &&
            requires_heightened_privileges? && Opium.config.master_key
        end

        def check_for_error( options = {}, &block )
          fail ArgumentError, 'no block given' unless block_given?
          result = yield
          if options[:raw_response] || options[:sent_headers]
            result
          else
            result = result.body
            result = result.is_a?(Hash) ? result.with_indifferent_access : {}
            fail ParseError.new( result[:code], result[:error] ) if result[:code] && result[:error]
            result
          end
        end
      end
    end
  end
end

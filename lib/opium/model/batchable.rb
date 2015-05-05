require 'opium/model/batchable/operation'
require 'opium/model/batchable/batch'

module Opium
  module Model
    module Batchable
      extend ActiveSupport::Concern
      
      require 'fiber'
      
      module ClassMethods
        def batch( options = {} )
          raise ArgumentError, 'no block given' unless block_given?
          create_batch
          fiber = Fiber.new { yield }
          subfibers = []
          subfibers << fiber.resume while fiber.alive?
        ensure
          delete_batch
        end
        
        def batched?
          batch_pool[Thread.current].present?
        end
        
        def create_batch
          batch = current_batch_job
          if batch
            batch.dive && batch
          else
            self.current_batch_job = Batch.new
          end
        end
        
        def delete_batch
          batch = current_batch_job
          fail 'No current batch job!' unless batch
          if batch.depth == 0
            self.current_batch_job = nil
          else
            batch.execute
            batch
          end
        end
        
        def current_batch_job
          batch_pool[Thread.current]
        end
        
        def current_batch_job=( value )
          batch_pool[Thread.current] = value
        end
        
        def http_post( data, options = {} )
          if batched?
            current_batch_job.enqueue( method: :post, path: resource_name, body: data )
            Fiber.yield
          else
            super
          end
        end
        
        def http_put( id, data, options = {} )
          if batched?
            current_batch_job.enqueue( method: :put, path: resource_name( id ), body: data )
            Fiber.yield
          else
            super
          end
        end
        
        def http_delete( id, options = {} )
          if batched?
            current_batch_job.enqueue( method: :delete, path: resource_name( id ) )
            Fiber.yield
          else
            super
          end
        end
        
        private
        
        def batch_pool
          @batch_pool ||= {}
        end
        
        def thread_local_id
          @thread_local_id ||= :"#{ Module.nesting.first.name.parameterize('_') }_current_batch_job"
        end
      end
    end
  end
end
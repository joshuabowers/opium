module Opium
  module Model
    module Batchable
      class Batch
        MAX_BATCH_SIZE = 50
        
        def initialize
          self.depth = 0
          self.queue = []
        end
        
        attr_accessor :depth, :queue, :owner
        
        def dive
          self.depth += 1
        end
        
        def ascend
          self.depth -= 1
        end
        
        def enqueue( operation )
          operation = Operation.new( operation ) if operation.is_a?( Hash )
          self.queue.push( operation ) && operation
        end
        
        def execute
          if depth > 0
            ascend
          else
            batches = to_parse
            fail 'no batches to process' if batches.empty?
            batches.each {|batch| owner.http_post( batch ) }
          end
        end
        
        def to_parse
          queue.each_slice(MAX_BATCH_SIZE).map {|operations| { requests: operations.map(&:to_parse) } }
        end
      end
    end
  end
end
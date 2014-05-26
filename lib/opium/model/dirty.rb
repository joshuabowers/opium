module Opium
  module Model
    module Dirty
      extend ActiveSupport::Concern
      include ActiveModel::Dirty
    end
  end
end
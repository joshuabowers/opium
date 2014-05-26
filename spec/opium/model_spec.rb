require 'spec_helper'

describe Opium::Model do
  its(:singleton_class) { should respond_to(:model_name) }
end
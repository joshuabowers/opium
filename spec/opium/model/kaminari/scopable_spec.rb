require 'spec_helper'

if defined?( Kaminari )
  describe Opium::Model::Scopable do
    describe 'when included in a class' do
      before do
        stub_const( 'Scoped', Class.new { include Opium::Model::Scopable } )
      end
      
      subject { Scoped }
      
      it { should <= Opium::Model::Scopable }
      it { should <= ::Kaminari::ConfigurationMethods }
      
      # Really, this just is a sanity check to verify that some of the kaminari methods
      # successfully were added.
      it { should respond_to( :max_per_page, :max_pages ) }
    end
  end
end
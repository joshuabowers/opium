require 'spec_helper'

if defined?( Kaminari )
  describe Opium::Model::Queryable do
    describe 'when included in a class' do
      before do
        stub_const( 'Query', Class.new { include Opium::Model::Queryable } )
      end
      
      subject { Query }
      
      it { should <= Opium::Model::Queryable }
      it { should <= ::Kaminari::PageScopeMethods }
      
      # Really, this just is a sanity check to verify that some of the kaminari methods
      # successfully were added.
      it { Query.new.should respond_to( :total_pages, :current_page ) }
    end
  end
end
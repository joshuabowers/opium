require 'spec_helper'

if defined?( Kaminari )
  describe Opium::Model::Queryable do
    describe 'when included in a class' do
      before do
        stub_const( 'Query', Class.new { include Opium::Model::Queryable } )
      end
      
      subject { Query }
      
      it { should <= Opium::Model::Queryable }
      it { Opium::Model::Queryable::ClassMethods <= ::Kaminari::PageScopeMethods }
      
      # Really, this just is a sanity check to verify that some of the kaminari methods
      # successfully were added.
      it { should respond_to( :total_pages, :current_page, :max_pages ) }
      it { should respond_to( Kaminari.config.page_method_name ).with(1).argument }
      it { should respond_to( :limit, :offset ) }
    end
  end
end
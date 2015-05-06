require 'spec_helper'

describe Opium::Model::Fieldable do
  describe "in a model without explicit fields" do
    let( :model ) { Class.new { include Opium::Model } }
    
    it { model.should respond_to( :fields ).with(0).arguments }
    it "should have #fields [:id, :created_at, :updated_at]" do
      model.fields.should be_a_kind_of( Hash )
      model.fields.should_not be_empty
      model.fields.keys.should =~ %w[id created_at updated_at]
      model.fields.values.each do |f|
        f.should be_a_kind_of( Opium::Model::Field )
        f.should be_readonly
      end
    end
  end
  
  describe "in a model with fields" do
    let( :model ) do
      Class.new do
        include Opium::Model
        field :name, type: String, default: "default"
        field :price, type: Float, default: -> { 5.0 * 2 }
        field :no_cast
        field :cannot_be_directly_changed, readonly: true
      end
    end
  
    it { model.should respond_to( :field ).with(2).arguments }
    it { model.should respond_to( :fields ).with(0).arguments }
    it { model.should respond_to( :ruby_canonical_field_names ) }
    it { model.should respond_to( :parse_canonical_field_names ) }
        
    it "should have #fields for every #field" do
      model.fields.should be_a_kind_of( Hash )
      model.fields.should_not be_empty
      model.fields.keys.should =~ %w[name price no_cast cannot_be_directly_changed id created_at updated_at]
      model.fields.values.each do |f|
        f.should_not be_nil
        f.should be_a_kind_of( Opium::Model::Field )
      end 
    end
    
    it "each #fields should have a #name, #as, #type, #default, #readonly, #readonly?" do
      model.fields.values.each do |f|
        f.should respond_to(:name, :as, :type, :default, :readonly, :readonly?)
      end
    end
    
    it "each #fields should have the type they were defined with" do
      expected = {name: String, price: Float, no_cast: Object, cannot_be_directly_changed: Object, id: String, created_at: DateTime, updated_at: DateTime}
      model.fields.values.each do |f|
        f.type.should == expected[ f.name.to_sym ]
      end
    end
    
    it "each #fields should have the default they were defined with" do
      expected = {name: "default", price: 10.0, no_cast: nil}
      model.fields.values.each do |f|
        f.default.should == expected[ f.name.to_sym ]
      end
    end
    
    it "each #fields should convert ruby names to parse names" do
      expected = {name: "name", price: "price", no_cast: "noCast", cannot_be_directly_changed: "cannotBeDirectlyChanged", id: "objectId", created_at: "createdAt", updated_at: "updatedAt"}
      model.fields.values.each do |f|
        f.name_to_parse.should == expected[ f.name.to_sym ]
      end
    end
        
    it "should return the canonical ruby form of a given field name" do
      expected = {name: 'name', price: 'price', noCast: 'no_cast', cannotBeDirectlyChanged: 'cannot_be_directly_changed', objectId: 'id', createdAt: 'created_at', updatedAt: 'updated_at'}
      expected.each do |field_alias, expected_field_name|
        model.ruby_canonical_field_names[field_alias].should == expected_field_name
      end
    end
    
    it "should return the canonical parse form of a given field name" do
      expected = {name: 'name', price: 'price', no_cast: 'noCast', cannot_be_directly_changed: 'cannotBeDirectlyChanged', id: 'objectId', created_at: 'createdAt', updated_at: 'updatedAt'}
      expected.each do |field_alias, expected_field_name|
        model.parse_canonical_field_names[field_alias].should == expected_field_name
      end
    end
    
    it { model.should respond_to( :default_attributes ) }
    
    it "default_attributes should return its #fields default" do
      expected = {"name" => "default", "price" => 10.0, "no_cast" => nil, "cannot_be_directly_changed" => nil, "id" => nil, "created_at" => nil, "updated_at" => nil}
      model.default_attributes.should == expected
    end
  
    describe "instance" do
      subject { model.new }
      
      it "should not have setters for readonly fields" do
        should_not respond_to( :cannot_be_directly_changed= ) 
      end
      
      {name: "42", price: 42.0}.each do |field_name, expected_value|
        it "should have a getter and setter for its fields" do
          should respond_to( field_name ).with(0).arguments
          should respond_to( :"#{field_name}=" ).with(1).argument
        end
    
        it "should have a dirty tracking method for its fields" do
          should respond_to( :"#{field_name}_will_change!" )
        end
    
        it "should receive a dirty tracking update when the setter is called with a new value" do
          subject.should_receive :"#{field_name}_will_change!"
          subject.send(:"#{field_name}=", "changed!")
        end
    
        it "should not receive a dirty tracking update when the setter is called with the current value" do
          subject.send(:"#{field_name}=", "current")
          subject.should_not_receive :"#{field_name}_will_change!"
          subject.send(:"#{field_name}=", "current")
        end
        
        it "should call the :to_ruby conversion method on the field type on setting" do
          model.fields[field_name].type.should_receive(:to_ruby).at_least(:once)
          subject.send(:"#{field_name}=", "42")
        end
        
        it "should convert the value passed to its setter to the field's type" do
          subject.send(:"#{field_name}=", "42")
          subject.send(:"#{field_name}").should == expected_value
        end
      end
    end
  end
  
  context 'when a model has fields' do
    before do
      stub_const( 'Model', Class.new do
        include Opium::Model
        field :symbolic_with_string_default, type: Symbol, default: 'value'
        field :symbolic_with_symbol_default, type: Symbol, default: :value
      end )
    end
    
    subject { Model }
    let(:instance) { subject.new }
    
    it 'converts default values correctly' do
      expect( Model.default_attributes ).to include( 'symbolic_with_string_default' => :value, 'symbolic_with_symbol_default' => :value )
    end
    
    describe '.has_field?' do
      let(:result) { subject.has_field? field_name }
      
      context 'with a valid field_name' do
        let(:field_name) { :symbolic_with_string_default }
        
        it { expect( result ).to be_truthy }
      end
      
      context 'with an invalid field_name' do
        let(:field_name) { :not_defined }
        
        it { expect( result ).to be_falsey }
      end
    end
    
    describe '.field' do
      subject { Model.new }
      
      it 'converts default values' do
        expect( subject.symbolic_with_string_default ).to be_a Symbol
        expect( subject.symbolic_with_symbol_default ).to be_a Symbol
      end
    end
    
    describe '.field=' do
      subject { Model.new }
      
      it 'converts strings appropriately' do
        expect { subject.symbolic_with_symbol_default = 'updated_value' }.to change( subject, :symbolic_with_symbol_default ).from(:value).to(:updated_value)
        expect( subject.symbolic_with_symbol_default ).to be_a Symbol
      end
    end
  end
end
require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(DataMapper)
  puts "** require 'dm-core' to run the specs in #{__FILE__}"
else  
  
  DataMapper.setup(:default, 'sqlite::memory:')
  
  module DmOrmSpec
    class User
      include DataMapper::Resource
      property :id,   Serial
      property :name, String
      property :rating, Integer
      has n, :notes, :child_key => [:owner_id]
    end

    class Note
      include DataMapper::Resource
      property :id,   Serial
      property :body, String
      belongs_to :owner, 'User'
    end

    class CompositePrimaryKey
      include DataMapper::Resource
      property :key1, String, :key => true
      property :key2, String, :key => true
    end
    
    require  'dm-migrations'
    DataMapper.finalize
    DataMapper.auto_migrate!
  
    # here be the specs!
    describe DataMapper::Resource::OrmAdapter do
      before do
        User.destroy
        Note.destroy
        CompositePrimaryKey.destroy
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
        
        def reload_model(model)
          model.class.get(model.id)
        end
      end

      describe "composite primary key" do
        def create_composite_primary_key
          CompositePrimaryKey.create(:key1 => "key1", :key2 => "key2")
        end

        let(:composite_primary_key_adapter) { CompositePrimaryKey.to_adapter }

        describe "#get!(id)" do
          it "should allow to_key like arguments" do
            composite_primary_key = create_composite_primary_key
            composite_primary_key_adapter.get!(composite_primary_key.to_key).should == composite_primary_key
          end

          it "should raise an error if there is no instance with that id" do
            lambda { composite_primary_key_adapter.get!(["nonexistent id", "nonexistent id"]) }.should raise_error
          end
        end

        describe "#get(id)" do
          it "should allow to_key like arguments" do
            composite_primary_key = create_composite_primary_key
            composite_primary_key_adapter.get(composite_primary_key.to_key).should == composite_primary_key
          end

          it "should return nil if there is no instance with that id" do
            composite_primary_key_adapter.get(["nonexistent id", "nonexistent id"]).should be_nil
          end
        end
      end
    end
  end
end

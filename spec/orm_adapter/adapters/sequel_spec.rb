require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(Sequel)
  puts "** require 'sequel' to run the specs in #{__FILE__}"
else  
  
  module SequelOrmSpec
    DB = Sequel.sqlite
    DB.create_table(:users) do
      primary_key :id
      String :name
      Integer :rating
    end
    DB.create_table(:notes) do
      primary_key :id
      String :body
      Integer :owner_id
    end

    class User < Sequel::Model
    end

    class Note < Sequel::Model
    end

    User.one_to_many :notes, :class=>Note, :key=>:owner_id
    Note.many_to_one :owner, :class=>User
    
    # here be the specs!
    describe Sequel::Model::OrmAdapter do
      before do
        User.destroy
        Note.destroy
      end
      
      describe "the OrmAdapter class" do
        subject { Sequel::Model::OrmAdapter }

        specify "#model_classes should return all of the non abstract model classes (that are not in except_classes)" do
          subject.model_classes.should == [User, Note]
        end
      end

      it_should_behave_like "example app with orm_adapter" do
        def create_model(klass, attrs = {})
          klass.create(attrs)
        end
  
        let(:user_class) { User }
        let(:note_class) { Note }
        
        def reload_model(model)
          model.reload
        end
      end
    end
  end
end

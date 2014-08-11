require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(Mongoid) || !(Mongo::Connection.new.db('orm_adapter_spec') rescue nil)
  puts "** require 'mongoid' and start mongod to run the specs in #{__FILE__}"
else

  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db('orm_adapter_spec')
  end

  module MongoidOrmSpec
    class User
      include Mongoid::Document
      field :name
      field :rating
      has_many_related :notes, :foreign_key => :owner_id, :class_name => 'MongoidOrmSpec::Note'
    end

    class Note
      include Mongoid::Document
      field :body, :default => "made by orm"
      belongs_to_related :owner, :class_name => 'MongoidOrmSpec::User'
    end

    # here be the specs!
    describe Mongoid::Document::OrmAdapter do
      before do
        User.delete_all
        Note.delete_all
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }

        describe "#find_collection" do
          let(:note_adapter) { note_class.to_adapter }
          let(:user_adapter) { user_class.to_adapter }
          describe "(conditions)" do
            it "should return only models matching conditions" do
              user1 = create_model(user_class, :name => "Fred")
              user2 = create_model(user_class, :name => "Fred")
              user3 = create_model(user_class, :name => "Betty")
              user_adapter.find_collection(:name => "Fred").should == [user1, user2]
            end

            it "should return all models if no conditions passed" do
              user1 = create_model(user_class, :name => "Fred")
              user2 = create_model(user_class, :name => "Fred")
              user3 = create_model(user_class, :name => "Betty")
              user_adapter.find_collection.should == [user1, user2, user3]
            end

            it "should return empty array if no conditions match" do
              user_adapter.find_collection(:name => "Fred").should == []
            end

            it "when conditions contain associated object, should return first model if it exists" do
              user1, user2 = create_model(user_class), create_model(user_class)
              note1 = create_model(note_class, :owner => user1)
              note2 = create_model(note_class, :owner => user2)
              note_adapter.find_collection(:owner => user2).should == [note2]
            end
          end

          describe "(:order => <order array>)" do
            it "should return all models in specified order" do
              user1 = create_model(user_class, :name => "Fred", :rating => 1)
              user2 = create_model(user_class, :name => "Fred", :rating => 2)
              user3 = create_model(user_class, :name => "Betty", :rating => 1)
              user_adapter.find_collection(:order => [:name, [:rating, :desc]]).should == [user3, user2, user1]
            end
          end

          describe "(:conditions => <conditions hash>, :order => <order array>)" do
            it "should return only models matching conditions, in specified order" do
              user1 = create_model(user_class, :name => "Fred", :rating => 1)
              user2 = create_model(user_class, :name => "Fred", :rating => 2)
              user3 = create_model(user_class, :name => "Betty", :rating => 1)
              user_adapter.find_collection(:conditions => {:name => "Fred"}, :order => [:rating, :desc]).should == [user2, user1]
            end
          end

          it "should return Mongoid::Criteria class" do
            user_class.to_adapter.find_collection.class.should == Mongoid::Criteria
          end
        end
      end
    end
  end
end

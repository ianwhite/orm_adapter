require 'spec_helper'

if !defined?(Mongoid) || !(Mongo::Connection.new.db('orm_adapter_spec') rescue nil)
  puts "** require 'mongoid' start mongod to run the specs in #{__FILE__}"
else  
  
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new.db('orm_adapter_spec')
  end
  
  module MongoidOrmSpec
    class User
      include Mongoid::Document
      field :name
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
      
      subject { Mongoid::Document::OrmAdapter }
    
      specify "model_classes should return all of mongoid resources" do
        (subject.model_classes & [User, Note]).to_set.should == [User, Note].to_set
      end
    
      describe "get_model(klass, id)" do
        specify "should return the instance of klass with id if it exists" do
          user = User.create!
          User.to_adapter.get_model(user.id).should == user
        end
      
        specify "should raise an error if the klass does not have an instance with that id" do
          lambda { User.to_adapter.get_model(1) }.should raise_error
        end
      end
    
      describe "find_first_model(klass, conditions)" do
        specify "should return first model matching conditions, if it exists" do
          user = User.create! :name => "Fred"
          User.to_adapter.find_first_model(:name => "Fred").should == user
        end

        specify "should return nil if no conditions match" do
          User.to_adapter.find_first_model(:name => "Betty").should == nil
        end
      
        specify "should handle belongs_to objects in attributes hash" do
          user = User.create!
          note = Note.create! :owner => user
          Note.to_adapter.find_first_model(:owner => user).should == note
        end
      end
    
      describe "find_all_models(klass, conditions)" do
        specify "should return all models matching conditions" do
          user1 = User.create! :name => "Fred"
          user2 = User.create! :name => "Fred"
          user3 = User.create! :name => "Betty"
          User.to_adapter.find_all_models(:name => "Fred").should == [user1, user2]
        end

        specify "should return empty array if no conditions match" do
          User.to_adapter.find_all_models(:name => "Betty").should == []
        end
      
        specify "should handle belongs_to objects in conditions hash" do
          user1, user2 = User.create!, User.create!
          note1, note2 = Note.create!(:owner_id => user1.id), Note.create!(:owner_id => user2.id)
          Note.to_adapter.find_all_models(:owner => user1).should == [note1]
        end
      end

      describe "create_model(klass, attributes)" do
        it "should create a model using the given attributes" do
          User.to_adapter.create_model(:name => "Fred")
          User.last.name.should == "Fred"
        end
      
        it "should raise error if the create fails" do
          lambda { User.to_adapter.create_model(foo) }.should raise_error
        end
      
        it "should handle belongs_to objects in attributes hash" do
          user = User.create!
          Note.to_adapter.create_model(:owner => user)
          Note.last.owner.should == user
        end
      end
      
      describe "<model class>#to_adapter" do
        it "should return an adapter instance for the receiver" do
          User.to_adapter.should be_a(OrmAdapter::Base)
          User.to_adapter.klass.should == User
        end
      end
    end
  end
end
require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(ActiveRecord::Base)
  puts "** require 'active_record' to run the specs in #{__FILE__}"
else  
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:users, :force => true) {|t| t.string :name; t.integer :rating; }
      create_table(:notes, :force => true) {|t| t.belongs_to :owner, :polymorphic => true }
    end
  end
  
  module ArOrmSpec
    class User < ActiveRecord::Base
      has_many :notes, :as => :owner
    end

    class AbstractNoteClass < ActiveRecord::Base
      self.abstract_class = true
    end

    class Note < AbstractNoteClass
      belongs_to :owner, :polymorphic => true
    end
  
    # here be the specs!
    describe '[ActiveRecord orm adapter]' do
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

          it "should return ActiveRecord::Relation class" do
            user_class.to_adapter.find_collection.class.should == ActiveRecord::Relation
          end
        end
      end
      
      describe "#conditions_to_fields" do
        describe "with non-standard association keys" do
          class PerverseNote < Note
            belongs_to :user, :foreign_key => 'owner_id'
            belongs_to :pwner, :polymorphic => true, :foreign_key => 'owner_id', :foreign_type => 'owner_type'
          end
          
          let(:user) { User.create! }
          let(:adapter) { PerverseNote.to_adapter }
          
          it "should convert polymorphic object in conditions to the appropriate fields" do
            adapter.send(:conditions_to_fields, :pwner => user).should == {'owner_id' => user.id, 'owner_type' => user.class.name}
          end
          
          it "should convert belongs_to object in conditions to the appropriate fields" do
            adapter.send(:conditions_to_fields, :user => user).should == {'owner_id' => user.id}
          end
        end
      end
    end
  end
end
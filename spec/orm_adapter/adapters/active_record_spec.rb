require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(ActiveRecord::Base)
  puts "** require 'active_record' to run the specs in #{__FILE__}"
else  
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ":memory:")

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define(:version => 0) do
      create_table(:users, :force => true) {|t| t.string :name; t.belongs_to :site }
      create_table(:notes, :force => true) {|t| t.belongs_to :owner, :polymorphic => true }
    end
  end
  
  module ArOrmSpec
    class User < ActiveRecord::Base
      belongs_to :site, :class_name => "ArOrmSpec::Site"
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

      describe "the OrmAdapter class" do
        subject { ActiveRecord::Base::OrmAdapter }

        specify "#except_classes should return the names of active record session store classes" do
          subject.except_classes.should == ["CGI::Session::ActiveRecordStore::Session", "ActiveRecord::SessionStore::Session"]
        end

        specify "#model_classes should return all of the non abstract model classes (that are not in except_classes)" do
          subject.model_classes.should == [User, Note]
        end
      end
    
      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end
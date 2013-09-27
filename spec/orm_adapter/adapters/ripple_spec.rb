require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(Ripple) || !(Riak::Client.new['orm_adapter_spec'] rescue nil)
  puts "** require 'ripple_mapper' and start riak to run the specs in #{__FILE__}"
else

  Ripple.connection = Riak::Client.new
  Ripple.database = "orm_adapter_spec"


  module RippleOrmSpec
    class User
      include Ripple::Document
      key :name
      key :rating
      many :notes, :foreign_key => :owner_id, :class_name => 'RippleOrmSpec::Note'
    end

    class Note
      include Ripple::Document
      key :body, :default => "made by orm"
      belongs_to :owner, :class_name => 'RippleOrmSpec::User'
    end

    # here be the specs!
    describe Ripple::Document::OrmAdapter do

      before do
        Ripple.database.collections.each do | coll |
          coll.remove
        end
      end
    
      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end
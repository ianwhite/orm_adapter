require 'spec_helper'
require 'orm_adapter/example_app_shared'

if !defined?(ActiveResource::Base)
  puts "** require 'active_resource' to run the specs in #{__FILE__}"
else
  module ActiveResourceOrmSpec
    class User < ActiveResource::Base
      self.site = "http://localhost:31777/"
      schema do
        string 'name'
        integer 'rating'
      end
      def notes; Note.find(:all, :params => {:owner_id => id}) || []; end
    end

    class Note < ActiveResource::Base
      self.site = "http://localhost:31777/"
      schema do
        integer 'owner_id'
      end
      def owner; User.find(owner_id); end
    end
  
    # here be the specs!
    describe ActiveResource::Base::OrmAdapter do
      before(:all) do
        @server_pid = fork do
          server_dir = File.expand_path(__FILE__ + '/../active_resource_server')
          FileUtils.rm(server_dir + '/server.log') rescue nil
          $stdout.reopen('/dev/null', 'w')
          $stderr.reopen('/dev/null', 'w')
          exec('bundle exec rackup -p 31777 ' + server_dir + '/config.ru')
        end
        sleep 5
      end
      after(:all) do
        Process.kill "KILL", @server_pid 
        Process.waitpid @server_pid
      end

      before do
        User.find(:all).each {|u| u.destroy }
        Note.find(:all).each {|n| n.destroy }
      end

      describe "the OrmAdapter class" do
        subject { ActiveResource::Base::OrmAdapter }

        specify "#model_classes should return all model classes" do
          subject.model_classes.should include(User, Note)
        end
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }

        def create_model(klass, attrs = {})
          klass.create(attrs)
        end
      end
    end
  end
end

# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../server',  __FILE__)
run ActiveResourceServer::Application

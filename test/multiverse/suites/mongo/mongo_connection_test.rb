# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

require 'mongo'
require 'newrelic_rpm'
require 'new_relic/agent/datastores/mongo'
require 'securerandom'
require File.join(File.dirname(__FILE__), '..', '..', '..', 'agent_helper')

if NewRelic::Agent::Datastores::Mongo.is_supported_version?
  require File.join(File.dirname(__FILE__), '..', '..', '..', 'helpers', 'mongo_metric_builder')
  require File.join(File.dirname(__FILE__), 'helpers', 'mongo_server')
  require File.join(File.dirname(__FILE__), 'helpers', 'mongo_replica_set')
  require File.join(File.dirname(__FILE__), 'helpers', 'mongo_operation_tests')

  class NewRelic::Agent::Instrumentation::MongoConnectionTest
    include Mongo
    include ::NewRelic::TestHelpers::MongoMetricBuilder
    include ::MongoOperationTests

    @@server = MongoServer.new
    @@server.start
    at_exit { @@server.stop }

    def setup
      @client = Mongo::Connection.new('localhost', @@server.port)
      @database_name = 'multiverse'
      @database = @client.db(@database_name)
      @collection_name = 'tribbles'
      @collection = @database.collection(@collection_name)

      @tribble = {'name' => 'soterios johnson'}

      NewRelic::Agent::Transaction.stubs(:recording_web_transaction?).returns(true)
      NewRelic::Agent.drop_buffered_data
    end

    def teardown
      NewRelic::Agent.drop_buffered_data
      @client.drop_database(@database_name)
    end
  end
end
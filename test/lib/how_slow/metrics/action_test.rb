require 'test/test_helper'

class BaseTest < MiniTest::Unit::TestCase
  describe HowSlow::Metrics::Action do
    it 'converts to JSON as expected' do
      params_hash = {
        :datetime => '2010-01-08 12:00:00 UTC',
        :event_name => 'metric test',
        :meta => {:this_is => "only a test"},
        :status => 200,
        :total_runtime => 1000.0,
        :db_runtime => 600.0,
        :view_runtime => 300,
        :other_runtime => 100,
        :params => {:controller => 'sample_controller', :action => 'sample_action'}
      }

      expected_json = {
        'datetime' => '2010-01-08 12:00:00 UTC',
        'event_name' => 'metric test',
        'meta' => {:this_is => "only a test"},
        'type_name' => 'action',
        'status' => 200,
        'total_runtime' => 1000.0,
        'db_runtime' => 600.0,
        'view_runtime' => 300,
        'other_runtime' => 100,
        'params' => {:controller => 'sample_controller', :action => 'sample_action'},
        'controller' => 'sample_controller',
        'action' => 'sample_action'
     }


      action_metric =  HowSlow::Metrics::Action.new(params_hash)

      assert_equal expected_json, action_metric.as_json
    end
  end
end

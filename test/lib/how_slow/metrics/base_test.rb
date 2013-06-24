require File.expand_path(File.join(File.dirname(__FILE__), '../../../../test/test_helper'))

class BaseTest < MiniTest::Unit::TestCase
  describe HowSlow::Metrics::Base do
    it 'converts to JSON as expected' do
      params_hash = {
        :datetime => '2010-01-08 12:00:00 UTC',
        :event_name => 'metric test',
        :meta => {:this_is => "only a test"}
      }

      expected_json = {
        'datetime' => '2010-01-08 12:00:00 UTC',
        'event_name' => 'metric test',
        'meta' => {:this_is => "only a test"},
        'type_name' => 'metric'
      }


      base_metric = HowSlow::Metrics::Base.new(params_hash)

      assert_equal expected_json, base_metric.as_json
    end
  end
end

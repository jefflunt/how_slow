require 'test/test_helper'

class ReporterTest < MiniTest::Unit::TestCase
  describe HowSlow do
    def setup
      Time.stubs(:now).returns(Time.parse('2013-01-08 12:10:00 UTC'))
      HowSlow.stubs(:full_path_to_log_file).returns('test/log/test_metrics.log')
      @expected_initial_or_reset_state = lambda {
        HashWithIndifferentAccess.new({
          :action => [],
          :counter => []
        })
      }

      @reporter = HowSlow::Reporter.new
    end

    # All metrics happen to be sorted such that no matter which timing metric by
    # which you sort them, they will end up in the same order. This is simply a
    # convenience thing for testing.
    def slowest_actions_by_each_timing_metric
      [HowSlow::Metrics::Action.new(
        :total_runtime=>900.0,
        :db_runtime=>400.0,
        :view_runtime=>450.0,
        :other_runtime=>50.0,
        :event_name=>"all_requests",
        :params=>{},
        :status=>200,
        :datetime=>'2013-01-08 12:00:00 UTC'
      ), HowSlow::Metrics::Action.new(
        :total_runtime=>800.0,
        :db_runtime=>400.0,
        :view_runtime=>350.0,
        :other_runtime=>50.0,
        :event_name=>"all_requests",
        :params=>{},
        :status=>200,
        :datetime=>'2013-01-08 12:01:00 UTC'
      ), HowSlow::Metrics::Action.new(
        :total_runtime=>700.0,
        :db_runtime=>400.0,
        :view_runtime=>250.0,
        :other_runtime=>50.0,
        :event_name=>"all_requests",
        :params=>{},
        :status=>200,
        :datetime=>'2013-01-08 12:02:00 UTC'
      ), HowSlow::Metrics::Action.new(
        :total_runtime=>600.0,
        :db_runtime=>400.0,
        :view_runtime=>150.0,
        :other_runtime=>50.0,
        :event_name=>"all_requests",
        :params=>{},
        :status=>200,
        :datetime=>'2013-01-08 12:03:00 UTC'
      ), HowSlow::Metrics::Action.new(
        :total_runtime=>500.0,
        :db_runtime=>300.0,
        :view_runtime=>150.0,
        :other_runtime=>50.0,
        :event_name=>"all_requests",
        :params=>{},
        :status=>200,
        :datetime=>'2013-01-08 12:04:00 UTC'
      )]
    end

    it 'the initial state of a new reporter will contain all loaded metrics' do
      refute_nil @reporter.metrics[:action]
      assert_equal 10, @reporter.metrics[:action].size
      
      refute_nil @reporter.metrics[:counter]
      assert_equal 7, @reporter.metrics[:counter].size
    end

    context '#slowest_actions_by' do
      it 'passing an unknown measurement attribute with throw a NoMethodError' do
        assert_raises(NoMethodError) { @reporter.slowest_actions_by(:some_unknown_attribute) }
      end

      it 'passing :total_runtime will give you a list of 5 metrics within the last 7 days be default, sorted by :total_runtime' do
        @reporter.slowest_actions_by(:total_runtime).each_with_index do |m, i|
          assert_equal slowest_actions_by_each_timing_metric[i].as_json, m.as_json
        end
      end

      context 'with various number_of_actions values' do
        it 'the number_of_actions argument will default to 5' do
          assert_equal 5, @reporter.slowest_actions_by(:total_runtime).size
        end

        it 'when number_of_actions is nil all metrics within the default keep_since threshold will be returned' do
          # Assuming a total number of 10 action metrics in the file
          assert_equal 10, @reporter.slowest_actions_by(:total_runtime, nil).size
        end

        it 'when number_of_actions is 2 you will get no more than 2 metrics back' do
          assert_equal 2, @reporter.slowest_actions_by(:total_runtime, 2).size
        end

        it 'when number_of_actions exceeds the total number of action metrics then all action metrics will be returned' do
          assert_equal 10, @reporter.slowest_actions_by(:total_runtime, 9999).size
        end
      end

      context 'with various keep_since values' do
        it 'the keep_since argument will default to 7.days.ago' do
          assert_equal 10, @reporter.slowest_actions_by(:total_runtime, nil).size
        end

        it 'when keep_since is nil all action metrics will be returned' do
          assert_equal 10, @reporter.slowest_actions_by(:total_runtime, nil, nil).size
        end

        it 'when keep_since is set to 5.minutes.ago then only action metrics newer than that will be returned' do
          assert_equal 5, @reporter.slowest_actions_by(:total_runtime, nil, 5.minutes.ago).size
        end

        it 'when keep_since exceeds the maximum age of the oldest action metric then all action metrics are returned' do
          assert_equal 10, @reporter.slowest_actions_by(:total_runtime, nil, 1000.years.ago).size
        end
      end
    end #slowst_actions_by context

    context '#sum_counters_by' do
      context 'with various event_name values' do
        it 'when event_name is nil the sum returned is always zero' do
          assert_equal 0, @reporter.sum_counters_by(nil)
        end

        it 'when event_name matches no known counter metric event names, the sum returned is zero' do
          assert_equal 0, @reporter.sum_counters_by('unknown event name')
        end

        it 'when the event_name matches a known counter metric event name the sum returned is the sum of all the count attributes' do
          assert_equal 35, @reporter.sum_counters_by('some count')
        end
      end

      context 'with various keep_since values' do
        it 'defaults to 7.days.ago' do
          assert_equal 35, @reporter.sum_counters_by('some count')
        end

        it 'will only sum the counter metrics within the threshold' do
          assert_equal 12, @reporter.sum_counters_by('some count', 5.minutes.ago)
        end

        it 'will sum all metrics if the threshold is beyond the age of the oldest counter metric' do
          assert_equal 35, @reporter.sum_counters_by('some count', 1000.years.ago)
        end
      end
    end
  end
end

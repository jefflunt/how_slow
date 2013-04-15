require 'test/test_helper'

class ReporterTest < MiniTest::Unit::TestCase
  describe HowSlow do
    def setup
      HowSlow.stubs(:full_path_to_log_file).returns('test/log/test_metrics.log')
      @expected_initial_or_reset_state = lambda {
        HashWithIndifferentAccess.new({
          :action => [],
          :counter => []
        })
      }

      @slowest_five_actions = [{
        "other_runtime"=>50.0,
        "db_runtime"=>400.0,
        "event_name"=>"all_requests",
        "params"=>{},
        "total_runtime"=>900.0,
        "status"=>200,
        "datetime"=>"2013-01-08 12:00:00 UTC",
        "view_runtime"=>450.0
      }, {
        "other_runtime"=>50.0,
        "db_runtime"=>400.0,
        "event_name"=>"all_requests",
        "params"=>{},
        "total_runtime"=>800.0,
        "status"=>200,
        "datetime"=>"2013-01-08 12:01:00 UTC",
        "view_runtime"=>350.0
      }, {
        "other_runtime"=>50.0,
        "db_runtime"=>400.0,
        "event_name"=>"all_requests",
        "params"=>{},
        "total_runtime"=>700.0,
        "status"=>200,
        "datetime"=>"2013-01-08 12:02:00 UTC",
        "view_runtime"=>250.0
      }, {
        "other_runtime"=>50.0,
        "db_runtime"=>400.0,
        "event_name"=>"all_requests",
        "params"=>{},
        "total_runtime"=>600.0,
        "status"=>200,
        "datetime"=>"2013-01-08 12:03:00 UTC",
        "view_runtime"=>150.0
      }, {
        "other_runtime"=>50.0,
        "db_runtime"=>300.0,
        "event_name"=>"all_requests",
        "params"=>{},
        "total_runtime"=>500.0,
        "status"=>200,
        "datetime"=>"2013-01-08 12:04:00 UTC",
        "view_runtime"=>150.0
      }]
    end

    def teardown
      HowSlow.reset_metrics
    end

    def test_the_initial_state_of_the_metrics_is_an_empty_set
      assert_equal @expected_initial_or_reset_state.call, HowSlow.metrics
    end

    def test_metrics_method_will_return_whatever_metrics_have_bee_read_from_the_log_file
      HowSlow.reset_metrics
      assert_equal @expected_initial_or_reset_state.call, HowSlow.metrics

      HowSlow.rebuild_metrics
      refute_equal @expected_initial_or_reset_state.call, HowSlow.metrics
    end

    def test_reset_metrics_method_will_reset_all_metrics_to_an_empty_set
      HowSlow.reset_metrics
      assert_equal @expected_initial_or_reset_state.call, HowSlow.metrics

      HowSlow.rebuild_metrics
      refute_equal @expected_initial_or_reset_state.call, HowSlow.metrics

      HowSlow.reset_metrics
      assert_equal @expected_initial_or_reset_state.call, HowSlow.metrics
    end

    # ::slowest_actions method
    #
    def test_specifying_no_arguments_will_give_you_the_five_slowest_metrics_of_all_time
      HowSlow.rebuild_metrics
      assert_equal @slowest_five_actions, HowSlow.slowest_actions
    end

    def test_specifying_a_maximum_of_5_slowest_metrics_will_return_5_metrics
      HowSlow.rebuild_metrics
      assert_equal @slowest_five_actions, HowSlow.slowest_actions(5)
    end

    def test_specifying_a_limited_number_of_metrics_will_limit_the_number_of_slow_metrics_to_that_number_maximum
      HowSlow.rebuild_metrics
      assert_equal @slowest_five_actions.first(2), HowSlow.slowest_actions(2)
    end

    def test_specifying_that_the_limit_on_metrics_be_higher_than_the_number_of_available_metrics_returns_all_metrics
      HowSlow.rebuild_metrics
      assert_equal HowSlow.metrics[:action].size, HowSlow.slowest_actions(9999).size
    end

    def test_specifying_a_time_limite_on_slow_metrics_will_limit_metrics_to_metrics_more_recent_than_that_time_limit
      Time.stubs(:now).returns(Time.parse("2013-01-08 12:10:00 UTC"))
      HowSlow.rebuild_metrics
      assert_equal HowSlow.metrics[:action].last(3), HowSlow.slowest_actions(99, (Time.now.utc-3.minutes).utc.to_s)
    end
  end
end

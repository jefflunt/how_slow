require 'test/test_helper'

module HowSlow::Metrics
  class BaseTest < MiniTest::Unit::TestCase
    def test_type_name_initial_value
      metric = HowSlow::Metrics::Base.new
      assert_equal 'metric', metric.type_name
    end
  end
end

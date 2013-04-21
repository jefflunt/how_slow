require 'active_support/hash_with_indifferent_access'

# Reports on the metrics gathered by the Collector class. Instantiating this
# class reads the entire log file into memory and allows you to get simple
# reports back.
#
# The metrics are stored as a hash, and available via the metrics attribute.
#
# The structure of the metrics hash is:
#
#   {
#     :action => [
#       { ...first 'action' metric... },
#       { ...second 'action' metric... },
#       ...
#     ],
#     :counter => [
#       { ...first 'counter' metric... },
#       { ...second 'counter' metric... },
#       ...
#     ]
#   }
#
# The order of the metrics under each metric type key (:action, or :counter)
# is the same as the order in which they were written to the log file.
#
module HowSlow
  class Reporter
    attr_reader :metrics
    @metrics

    def intitialize
      @metrics = HashWithIndifferentAccess.new({
        :action => [],
        :counter => []
      })
    end

    # Gives you a list of the slowest actions by :total_runtime, slowest first,
    # filtered to metrics recorded between now and keep_since time ago, and
    # limited to a maximum number by the number_of_actions argument.
    #
    # So, if you have the following set of metrics in the log file...
    #
    #   {'type':'action', 'total_runtime':123.0, ... }
    #   {'type':'action', 'total_runtime':456.7, ... }
    #   {'type':'action', 'total_runtime':99.0,  ... }
    #   {'type':'counter', ... }
    #   {'type':'action', 'total_runtime':3.0,   ... }
    # 
    # ...then
    #
    #   slowest_actions(2)
    #   => [{:total_runtime => 456.7, ... },
    #       {:total_runtime => 123.0, ... }]
    #
    # Notice that the 'counter' metric type is ignored by this method since the
    # purpose here is to get a list of the slowest actions.
    #
    # The default number_of_actions to return is 5 and it determines the maximum
    # number of metrics that will be returned by this method.
    #
    # The default keep_since value is nil, indicating that ALL logged metrics
    # should be considered. Pass in a value such as 7.days.ago to limit the
    # returned metrics to those whose :datetime attribute is within the last 7
    # days.
    # 
    def self.slowest_actions(number_of_actions=5, keep_since=nil)
      sorted_metrics = keep_since.nil? ? @metrics[:action] : @metrics[:action].reject{|metric| Time.parse(metric['datetime']) < keep_since}
      sorted_metrics = sorted_metrics.sort_by{|action| action['total_runtime']}
      sorted_metrics.last(number_of_actions).reverse
    end

    private

    def rebuild_metrics
      @metrics = @initial_state.call

      all_logged_metrics = []
      all_logged_lines = File.read(HowSlow.full_path_to_log_file).lines
      all_logged_lines.each{|line| all_logged_metrics << JSON.parse(line) unless line.start_with?('#')}
      all_logged_metrics.each do |metric|
        type = metric.delete('type')
        @metrics[type] << metric
      end

      @metrics
    end
  end
end

require 'active_support/hash_with_indifferent_access'

module HowSlow
  @initial_state = HashWithIndifferentAccess.new({
    :action => [],
    :counter => []
  })

  @metrics = @initial_state
  # Returns a hash of the metrics that have been logged to the log file. The 
  # metics must first be built by callng the `rebuld_metrics` method. The
  # reason you must call `rebuild_metrics` by hand is to separate the task of
  # collecting and constantly updating metrics from the reporting of the metrics
  # at a given point in time.
  #
  # The structure of the returned hash is:
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
  # NOTE that the 'type' attribute of the logged metrics is discarded when being
  # inserted into the metrics hash. This is because all metrics are placed under
  # a key that identifies their type as recorded in the metrics log, and keeping
  # that key in the metrics hash as well would be redundant.
  #
  # The order of the metrics under each metric type key (:action, or :counter)
  # is the same as the order in which they were written to the log file. NOTE
  # that this doesn't mean they're in perfect chronological order by the
  # datetime of the action since long-running actions, multiple threads, or
  # multiple app server instances that all write to the same log file can result
  # in metrics being logged somewhat out of strict chronological order. If you
  # need the metrics to be in ANY kind of strict order you should enforce this
  # yourself by sorting them by the attribute(s) that matters to you.
  #
  def self.metrics
    @metrics
  end

  # Sets the in-memory reporting metrics to an empty set, thereby marking any
  # old metrics for garbage collection. This method is primarily for freeing up
  # memory.
  def self.reset_metrics
    @metrics = @initial_state
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

  # Rebuilds the metrics hash, returning it as an instance of
  # ActiveSupport::HashWithIndifferentAccess
  #
  def self.rebuild_metrics
    @metrics = @initial_state

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

require 'active_support/hash_with_indifferent_access'

# Reports on the metrics gathered by the Collector class. Instantiating this
# class reads the entire log file into memory and allows you to get simple
# reports back.
#
# The metrics are stored as a hash, and available via the metrics attribute.
#
# The structure of the resulting metrics hash is:
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

    def initialize
      @metrics = HashWithIndifferentAccess.new({
        :action => [],
        :counter => []
      })

      all_logged_metrics = []
      all_logged_lines = File.read(HowSlow.full_path_to_log_file).lines
      all_logged_lines.each{|line| all_logged_metrics << JSON.parse(line).to_hash.symbolize_keys! unless line.start_with?('#')}
      all_logged_metrics.each do |metric_hash|
        type_name = metric_hash.delete(:type_name)
        case type_name
        when 'action' then @metrics[type_name] << HowSlow::Metrics::Action.new(metric_hash)
        when 'counter' then @metrics[type_name] << HowSlow::Metrics::Counter.new(metric_hash)
        end
      end
    end

    # Gives you a list of the slowest actions by 'measurement', slowest first,
    # filtered to metrics recorded between 'Time.now' and 'retention' time ago,
    # and then further limited to a maximum number of results as specified by the 
    # 'number_of_actions' argument.
    #
    # So, if you have the following set of metrics...
    #
    #   {'type':'action', 'total_runtime':123.0, ... }
    #   {'type':'action', 'total_runtime':456.7, ... }
    #   {'type':'action', 'total_runtime':99.0,  ... }
    #   {'type':'counter', 'count': 1, ... }
    #   {'type':'action', 'total_runtime':3.0,   ... }
    # 
    # ...then
    #
    #   slowest_actions_by(:total_runtime, { :number_of_actions => 2 })
    #   => [{:total_runtime => 456.7, ... },
    #       {:total_runtime => 123.0, ... }]
    #
    # The attributes that you can sort by are:
    #   [:total_runtime, :db_runtime, :view_runtime, :other_runtime]
    #
    # Notice that the 'counter' metric type is ignored by this method since the
    # purpose here is to get a list of the slowest actions.
    #
    # The default 'number_of_actions' is 5.
    #
    # The default 'retention' value is '7.days.ago', indicating that only actions
    # in the last week will be included by default.
    # 
    def slowest_actions_by(measurement, options={})
      default_options = HashWithIndifferentAccess.new({:number_of_actions => 5, :retention => 7.days.ago})
      options = default_options.merge(options)

      sorted_metrics = options[:retention].nil? ? @metrics[:action] : @metrics[:action].reject{|metric| Time.parse(metric.datetime) < options[:retention]}
      sorted_metrics = sorted_metrics.sort_by{|action| -action.try(measurement)}
      sorted_metrics = (options[:number_of_actions].nil? ? sorted_metrics : sorted_metrics[0..options[:number_of_actions]-1])
    end

    # Returns an array of all counter event names present in the current set of
    # metrics. For example, if you have recorded named counter events for:
    #
    # 'login'
    # 'new signup'
    # 'new post'
    #
    # ...then...
    #
    #  > reporter.all_counter_event_names
    # => ['login', 'new signup', 'new post']
    # The order of the event names is NOT guaranteed to be any particular order,
    # so you must sort them yourself if that is important to you.
    def all_counter_event_names
      @metrics[:counter].map(&:event_name).uniq
    end

    # Gives you the sum of the `count` attributes of all Counter metrics with
    # the time range specified between `Time.now` and `retention`.
    #
    # So, if you have the following set of metrics...
    #
    #   {'type':'action', 'total_runtime':99.0,  ... }
    #   {'type':'counter', 'event_name': 'user login', 'count': 1, ... }
    #   {'type':'counter', 'event_name': 'user login', 'count': 1, ... }
    #   {'type':'counter', 'event_name': 'user login', 'count': 1, ... }
    #   {'type':'counter', 'event_name': 'user login', 'count': 1, ... }
    #   {'type':'counter', 'event_name': 'user login', 'count': 1, ... }
    #   {'type':'action', 'total_runtime':3.0,   ... }
    #
    # ...then
    #
    #   sum_counters_by('user login', nil)
    #   => 5
    #   sum_counters_by('an unknown event', nil)
    #   => 0
    #
    # So, this method looks for all counter metrics named 'user login', finds 5
    # of them, and sums their 'count' attribte. Since all of their 'count'
    # attributes are 1, then the sum is 5.
    #
    # Similarly, if you pass in the name of a counter event that does't exist
    # you will always get 0.
    #
    # The default `retention` is `7.days.ago`. If you you'd prefer to get the
    # sum for a named counter for as far back as your metrics go, then pass
    # in `nil` for `retention` value.
    #
    def sum_counters_by(event_name, retention=7.days.ago)
      return 0 if event_name.nil?
      filtered_metrics = retention.nil? ? @metrics[:counter] : @metrics[:counter].reject{|metric| Time.parse(metric.datetime) < retention}
      filtered_metrics = filtered_metrics.select{|metric| metric.event_name == event_name}
      filtered_metrics.size == 0 ? 0 : filtered_metrics.collect{|metric| metric.count}.reduce(:+)
    end
  end
end

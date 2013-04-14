module HowSlow
  @metrics = {
    'action' => [],
    'counter' => []
  }

  # Returns a hash of the metrics that have been logged to the log file. The 
  # metics must first be built by callng the `rebuld_metrics` method. The
  # structure of the returned hash is:
  #
  #   {
  #     'action' => [
  #       {'type' => 'action', ... },
  #       {'type' => 'action', ... },
  #       ...
  #     ],
  #     'counter' => [
  #       {'type' => 'counter', ...},
  #       ...
  #     ]
  #   }
  #
  # The order of the metrics under each metric type key ('action', or 'counter')
  # is the same as the order in which they were written to the log file. NOTE
  # that this doesn't mean they're in perfect chronological order by the
  # datetime of the action since long-running actions, multiple threads,  or
  # multiple app server instances, all writing to the same log file can result
  # in metrics being logged somewhat out of strict chronological order. If you
  # need the metrics to be in ANY kind of strict order you should enforce this
  # yourself by sorting them by the attribute(s) that matters to you.
  #
  def self.metrics
    @metrics
  end
 
  # Gives you a list of the slowest actions by total_runtime, slowest first.
  #
  # So, if you have the following set of action metrics in the log file...
  #
  #   {'type':'action', 'total_runtime':123.0, ... }
  #   {'type':'action', 'total_runtime':456.7, ... }
  #   {'type':'action', 'total_runtime':99.0,  ... }
  #   {'type':'counter', ... }
  #   {'type':'action', 'total_runtime':3.0,   ... }
  # 
  # ...then
  #
  #   slowest_actions(nil, 2)
  #   => [{'type':'action', 'total_runtime':456.7}, 
  #       {'type':'action', 'total_runtime':123.0}]
  # 
  def self.slowest_actions(reject_older_than=7.days.ago, number_of_slowest=5)
    rebuild_metrics(reject_older_than)
    sorted_metrics = @metrics['actions'].sort_by!{|action| action['total_runtime']}
    sorted_metrics.last(number_of_slowest).reverse
  end

  # Rebuilds the metrics hash.
  #
  # You can specify a threshold number of days ago, such as `7.days.ago` as a
  # parameter to this method. The default is `nil`, which indicates that ALL
  # metrics from the log file should be returned, for as far back as the log 
  # file goes.
  #
  def self.rebuild_metrics(reject_older_than=nil)
    rebuild_start_time = Time.now

    @metrics['actions'] = []
    @metrics['counters'] = []

    all_logged_lines = File.read(HowSlow.full_path_to_log_file).lines
    all_logged_metrics = []
    all_logged_lines.each{|line| all_logged_metrics << JSON.parse(line) unless line.start_with?('#')}
    all_logged_metrics.reject!{|metric| Time.parse(metric['datetime']) < reject_older_than} unless reject_older_than.nil?
    all_logged_metrics.each{|metric| @metrics[metric['type']] << metric}

    @metrics['latest_rebuilt_runtime'] = (Time.now-rebuild_start_time)*1000

    @metrics
  end
end

module HowSlow
  @metrics = {
    'actions' => [],
    'counters' => []
  }
 
  # Gives you a list of the slowest actions by total_runtime, most slow first.
  #
  # So, if you have the following set of action metrics...
  #
  #   {'type':'action', 'total_runtime':123.0, ... }
  #   {'type':'action', 'total_runtime':456.7, ... }
  #   {'type':'action', 'total_runtime':99.0,  ... }
  #   {'type':'counter', ... }
  #   {'type':'action', 'total_runtime':3.0,   ... }
  # 
  # ...then
  #   slowest_actions(nil, 2)
  #   => [{'type':'action', 'total_runtime':456.7}, {'type':'action', 'total_runtime':123.0}]A
  #
  # So, you get an array of 'action' typ
  # 
  def self.slowest_actions(reject_older_than=7.days.ago, number_of_slowest=5)
    rebuild_metrics(reject_older_than)
    sorted_metrics = @metrics['actions'].sort_by!{|action| action['total_runtime']}
    sorted_metrics.last(number_of_slowest).reverse
  end

  private
    def self.rebuild_metrics(reject_older_than=7.days.ago)
      @metrics['actions'] = []
      @metrics['counters'] = []

      all_logged_metrics = File.read(HowSlow.full_path_to_log_file).lines.collect{|line| JSON.parse(line) unless line.start_with?("#")}
      puts all_logged_metrics.class
      puts all_logged_metrics.first.inspect
      puts all_logged_metrics.inspect
      all_logged_metrics.reject!{|metric| Time.parse(metric['datetime']) < reject_older_than} unless reject_older_than.nil?
      all_logged_metrics.each{|metric| @metrics[metric['type']].push(metric)}
    end
end

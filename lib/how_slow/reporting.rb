module HowSlow
  @metrics = {
    'actions' => [],
    'counters' => []
  }
 
  # Will return the slowest actions whose datetime is between reject_older_than < x < Time.now
  # The list is truncated to a maximum of number_of_oldest
  #
  # reject_older_than - you should pass in a value like "7.days.ago" or "5.hours.ago", etc. The default value
  #   is 7.days.ago, and will return actions from the previous 7 days up until the current time.
  # number_of_slowest - the maximum number of events you want in the list returned. You should pass integers
  #   >= 1 for this argument
  def slowest_actions(reject_older_than=7.days.ago, number_of_slowest=5)
    rebuild_metrics(days_in_past)
    sorted_metrics = @metrics['actions'].sort_by!{|action| action['total_runtime']}
    sorted_metrics.last(number_of_slowest).reverse
  end

  private
    def rebuild_metrics(reject_older_than=7.days.ago)
      @metrics['actions'] = []
      @metrics['counters'] = []

      all_logged_metrics = File.read(config[:logger_filename]).lines.each{|line| JSON.parse(line)}
      all_logged_metrics.reject!{|metric| Time.parse(metric['datetime'] < reject_older_than} unless reject_older_than.nil?
      all_logged_metrics.each{|metric| @metrics[metric['type']].push(metric)}
    end
end

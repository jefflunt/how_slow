require 'action_mailer'

class HowSlow::Mailer < ActionMailer::Base
  # This method expects an `options` hash in the following format:
  #
  # {
  #   :email_title => "My title" - optional - defaults to "<Rails.env.titleize> <app name> metrics"
  #   :actions => {
  #     :sort_by => :total_runtime,                           # which metric to use to sort the resulting list
  #                                                           # the default is :total_runtime
  #     :show_measurements => [:db_runtime, :view_runtime],   # one or more measurements to include
  #                                                           # the default includes all measurements
  #     :number_of_actions => 100,                            # number of action metrics to include
  #     :keep_since => 7.days.ago                             # how far back in time to include metrics
  #   },
  #   :counters => {
  #     :event_names => ['login', 'new signup'],  # the names of the counter events you want to include
  #     :keep_since => 7.days.ago                 # how far back in time to include metrics
  #     :sort => :alpha_asc                       # one of (:alpha_asc, :alpha_desc, :numeric_asc, :numeric_desc)
  #   }
  # }
  #
  # The elements of the hash above are all optional and have defaults.
  # [:email_title]                  
  # [:actions]                      - if not specified no actions will be included in the email
  # [:actions][:show_measurements]  - defaults to [:total_runtime, :db_runtime, :view_runtime] the order
  #                                   of the symbols in this array are reflected in the order in which
  #                                   they appear into the resulting email
  # [:actions][:number_of_actions]  - defaults to 5
  # [:actions][:keep_since]         - defaults to 7.days.ago
  #
  # [:counters]                     - if not specified no counters will be included in the email
  # [:counters][:event_names]       - defaults to nil, resulting in all counters being reported. the order
  #                                   of the symbols in this array are reflected in the order in which
  #                                   they appear into the resulting email
  # [:counters][:keep_since]        - defaults to 7.days.ago
  # [:counters][:sort]              - one of (:alpha_asc, :alpha_desc, :numeric_asc, :numeric_desc)
  #                                   defaults to :alpha_asc
  def metrics_email(options)
    @email_title ||= "#{Rails.env.titleize} #{Rails.application.class.to_s.split("::").first} metrics"
    HashWithIndifferentAccess.new(options) unless options.class == HashWithIndifferentAccess

    reporter = HowSlow::Reporter.new

    @action_metrics = []
    if options[:actions]
      @action_sort_by = optiones[:actions][:sort_by] || :total_runtime
      @measurements = options[:actions][:show_measurements] || [:total_runtime, :db_runtime, :view_runtime]
      @number_of_actions = options[:actions][:number_of_actions] || 5
      @action_keep_since = options[:actions][:keep_since] || 7.days.ago
      
      @action_metrics = slowest_actions_by(@action_sort_by, @number_of_actions, @action_keep_since)
   end

    @counter_metrics = []
    if options[:counters]
      event_names = options[:counters][:event_names] || HowSlow::Reporter.all_counter_event_names
      @counter_keep_since = options[:counters][:keep_since] || 7.days.ago

      @counter_sort_by = options[:counters] || :alpha_asc
      event_names.each{|e| counter_metrics << reporter.sum_counters_by(e, @counter_keep_since) }

      case @counter_sort_by
        when :alpha_asc     then counter_metrics.sort!{|a, b| a.event_name <=> b.event_name }
        when :alpha_desc    then counter_metrics.sort!{|a, b| b.event_name <=> a.event_name }
        when :numeric_asc   then counter_metrics.sort!{|a, b| a.count <=> b.count }
        when :numeric_desc  then counter_metrics.sort!{|a, b| b.count <=> a.count }
      end
    end
 end
end
